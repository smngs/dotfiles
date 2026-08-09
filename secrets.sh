#!/bin/bash
# Manage secrets that must not live in this (public) repository.
#
# SSH keys are stored in Bitwarden as "SSH key" items and served by rbw-agent,
# so no private key is ever written to disk. The ssh config is stored as a
# secure note because it carries hostnames and account names.
set -euo pipefail

SSH_CONFIG_ITEM="${SSH_CONFIG_ITEM:-dotfiles-ssh-config}"
SSH_KEY_ITEM="${SSH_KEY_ITEM:-SSH}"
SSH_CONFIG_PATH="${HOME}/.ssh/config"
LOCK_TIMEOUT="${RBW_LOCK_TIMEOUT:-300}"

# Hosts that authenticate by public key but have no authorized_keys file
SKIP_HOSTS_RE='^(github\.com|gitlab\.com|bitbucket\.org|ssh\.dev\.azure\.com)$'

# shell-logger.sh is deliberately not used here: its err() returns 100, which
# would abort the script under set -e before the message is acted on.
info ()   { printf '\033[0;32m[INFO]\033[0m %s\n' "$*"; }
notice () { printf '\033[0;34m[NOTICE]\033[0m %s\n' "$*"; }
warn ()   { printf '\033[0;33m[WARNING]\033[0m %s\n' "$*" >&2; }
err ()    { printf '\033[0;31m[ERROR]\033[0m %s\n' "$*" >&2; }

require_rbw () {
  if ! command -v rbw >/dev/null 2>&1; then
    err "rbw is not installed. Run 'make install' first."
    exit 1
  fi
}

require_configured () {
  require_rbw
  if ! rbw config show >/dev/null 2>&1; then
    err "rbw is not configured yet. Run 'make secrets-setup' first."
    exit 1
  fi
}

# Terminal pinentry on purpose: the agent is often driven over ssh, where a
# GUI prompt cannot be answered.
default_pinentry () {
  local p
  for p in pinentry-curses pinentry-tty pinentry; do
    if command -v "${p}" >/dev/null 2>&1; then
      echo "${p}"
      return
    fi
  done
  echo pinentry
}

# rbw uses $XDG_RUNTIME_DIR when present and falls back to a temp dir keyed by
# uid otherwise, so probe both.
ssh_agent_socket () {
  local tmp candidate
  tmp="${TMPDIR:-/tmp}"
  for candidate in \
    "${XDG_RUNTIME_DIR:-}/rbw/ssh-agent-socket" \
    "${tmp%/}/rbw-$(id -u)/ssh-agent-socket"; do
    if [ -S "${candidate}" ]; then
      echo "${candidate}"
      return 0
    fi
  done
  return 1
}

setup () {
  require_rbw

  if ! rbw config show >/dev/null 2>&1; then
    notice "Bitwarden email:"
    read -r email
    rbw config set email "${email}"

    notice "Server URL (leave blank for bitwarden.com):"
    read -r base_url
    if [ -n "${base_url}" ]; then
      rbw config set base_url "${base_url}"
    fi
  fi

  rbw config set pinentry "$(default_pinentry)"
  rbw config set lock_timeout "${LOCK_TIMEOUT}"

  info "rbw configured. pinentry=$(default_pinentry) lock_timeout=${LOCK_TIMEOUT}s"
  info "Run 'rbw login' once, then 'rbw unlock' to start the agent."
}

pull () {
  require_configured

  local tmp
  tmp="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm -f '${tmp}'" EXIT

  # The command substitution drops the trailing newline rbw appends, so the
  # file does not grow a blank line on every round trip.
  if ! printf '%s\n' "$(rbw get "${SSH_CONFIG_ITEM}" --field notes)" > "${tmp}"; then
    err "Could not read '${SSH_CONFIG_ITEM}' from the vault."
    err "Store the config first with: $(basename "$0") push"
    exit 1
  fi

  if [ ! -s "${tmp}" ]; then
    err "'${SSH_CONFIG_ITEM}' is empty. Refusing to overwrite ${SSH_CONFIG_PATH}."
    exit 1
  fi

  mkdir -p "$(dirname "${SSH_CONFIG_PATH}")"
  install -m 600 "${tmp}" "${SSH_CONFIG_PATH}"
  info "Wrote ${SSH_CONFIG_PATH} from '${SSH_CONFIG_ITEM}'."
}

# rbw cannot write items non-interactively: `rbw add` waits on $EDITOR and
# never returns without a tty. Writing therefore goes through the official
# bw CLI, which accepts JSON. Reading stays on rbw.
ensure_bw_session () {
  if ! command -v bw >/dev/null 2>&1; then
    err "bw is not installed. Run 'make install' first."
    exit 1
  fi
  if [ -n "${BW_SESSION:-}" ] && bw list items --session "${BW_SESSION}" >/dev/null 2>&1; then
    return 0
  fi

  # bw keeps its own credentials, separate from rbw's: the vault can be
  # unlocked in rbw while bw is not even logged in.
  local bw_status
  bw_status="$(bw status 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get("status",""))' 2>/dev/null)"
  if [ "${bw_status}" = "unauthenticated" ]; then
    err "bw is not logged in (rbw and bw hold separate credentials)."
    err "Run once, from a normal terminal:  bw login ${BW_EMAIL:-<email>}"
    exit 1
  fi
  # `bw unlock --raw` writes its prompt to stdout, so it breaks under command
  # substitution (ERR_USE_AFTER_CLOSE). Read the password here and hand it
  # over through the environment instead. /dev/tty is not usable in every
  # host terminal, so stdin is used directly.
  local pw
  printf 'Master password: '
  if ! IFS= read -rs pw; then
    printf '\n'
    err "Could not read the master password from stdin."
    exit 1
  fi
  printf '\n'

  BW_SESSION="$(BW_PASSWORD="${pw}" bw unlock --passwordenv BW_PASSWORD --raw)" || {
    err "Failed to unlock the vault."
    exit 1
  }
  unset pw
  export BW_SESSION
}

push () {
  require_rbw

  if [ ! -f "${SSH_CONFIG_PATH}" ]; then
    err "${SSH_CONFIG_PATH} does not exist."
    exit 1
  fi

  ensure_bw_session
  bw sync --session "${BW_SESSION}" >/dev/null 2>&1 || true

  local id
  id="$(bw list items --search "${SSH_CONFIG_ITEM}" --session "${BW_SESSION}" 2>/dev/null \
        | CFG_NAME="${SSH_CONFIG_ITEM}" python3 -c '
import json, os, sys
name = os.environ["CFG_NAME"]
for item in json.load(sys.stdin):
    if item.get("name") == name:
        print(item["id"])
        break
')"

  if [ -n "${id}" ]; then
    bw get item "${id}" --session "${BW_SESSION}" \
      | CFG_PATH="${SSH_CONFIG_PATH}" python3 -c '
import json, os, sys
item = json.load(sys.stdin)
item["notes"] = open(os.environ["CFG_PATH"]).read()
json.dump(item, sys.stdout)
' | bw encode | bw edit item "${id}" --session "${BW_SESSION}" >/dev/null
    info "Updated '${SSH_CONFIG_ITEM}' in the vault."
  else
    bw get template item --session "${BW_SESSION}" \
      | CFG_PATH="${SSH_CONFIG_PATH}" CFG_NAME="${SSH_CONFIG_ITEM}" python3 -c '
import json, os, sys
item = json.load(sys.stdin)
item["type"] = 2                      # secure note
item["secureNote"] = {"type": 0}
item["name"] = os.environ["CFG_NAME"]
item["notes"] = open(os.environ["CFG_PATH"]).read()
item["login"] = None
json.dump(item, sys.stdout)
' | bw encode | bw create item --session "${BW_SESSION}" >/dev/null
    info "Created '${SSH_CONFIG_ITEM}' in the vault."
  fi

  rbw sync >/dev/null 2>&1 || true

  # Reading back is the only proof the write landed; the previous
  # implementation reported success while storing nothing.
  local stored
  stored="$(rbw get "${SSH_CONFIG_ITEM}" --field notes 2>/dev/null | wc -c | tr -d ' ')"
  if [ "${stored}" -lt 10 ]; then
    err "Verification failed: the vault item is empty."
    exit 1
  fi
  info "Verified: ${stored} bytes readable from the vault."
}

# Host aliases from the ssh config, minus wildcard patterns
config_hosts () {
  [ -f "${SSH_CONFIG_PATH}" ] || return 0
  awk '/^[Hh]ost[ \t]/ {
         for (i = 2; i <= NF; i++)
           if ($i !~ /[*?!]/) print $i
       }' "${SSH_CONFIG_PATH}"
}

authorize_one () {
  local host="$1" line="$2" result

  if [[ "${host}" =~ ${SKIP_HOSTS_RE} ]]; then
    warn "${host}: managed through its web UI, skipping"
    return 0
  fi

  # The key travels over stdin so it is never interpolated into the remote
  # shell command. Matching ignores the trailing comment, which differs
  # between manual and scripted installs.
  result="$(printf '%s\n' "${line}" | ssh -o ConnectTimeout=10 "${host}" '
    key=$(cat)
    body=$(printf "%s" "$key" | awk "{print \$1\" \"\$2}")
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
    if grep -qF "$body" ~/.ssh/authorized_keys; then
      echo ALREADY
    else
      cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.bak
      printf "%s\n" "$key" >> ~/.ssh/authorized_keys
      echo ADDED
    fi
  ' 2>/dev/null)" || {
    err "${host}: could not connect"
    return 1
  }

  # Verify with a fresh connection; reusing a live ControlMaster would pass
  # even when the key was never accepted.
  if ssh -o BatchMode=yes -o ControlMaster=no -o ControlPath=none \
         -o ConnectTimeout=10 "${host}" true 2>/dev/null; then
    info "${host}: ${result:-?}, key authentication verified"
  else
    warn "${host}: ${result:-?}, but a fresh connection still failed"
    return 1
  fi
}

authorize () {
  require_configured

  local pubkey line hosts=() host failed=0 sock

  # Both the install and the verification need the vault key, which only the
  # rbw agent can offer.
  if sock="$(ssh_agent_socket)"; then
    export SSH_AUTH_SOCK="${sock}"
  else
    err "rbw's ssh agent is not running. Run 'rbw unlock' first."
    exit 1
  fi

  pubkey="$(rbw get "${SSH_KEY_ITEM}" --field public_key)" || {
    err "Could not read the public key from item '${SSH_KEY_ITEM}'."
    exit 1
  }
  if [ -z "${pubkey}" ]; then
    err "Item '${SSH_KEY_ITEM}' has no public key."
    exit 1
  fi
  line="${pubkey} ${SSH_KEY_ITEM}@bitwarden"

  if [ "$#" -gt 0 ]; then
    hosts=("$@")
  else
    while IFS= read -r host; do
      hosts+=("${host}")
    done < <(config_hosts)
  fi

  if [ "${#hosts[@]}" -eq 0 ]; then
    err "No hosts given and none found in ${SSH_CONFIG_PATH}."
    exit 1
  fi

  info "Authorizing '${SSH_KEY_ITEM}' on ${#hosts[@]} host(s)."
  for host in "${hosts[@]}"; do
    authorize_one "${host}" "${line}" || failed=$((failed + 1))
  done

  if [ "${failed}" -gt 0 ]; then
    err "${failed} host(s) failed."
    exit 1
  fi
}

status () {
  require_configured

  echo "rbw:        $(rbw --version)"
  echo "pinentry:   $(default_pinentry)"
  echo "vault:      $(rbw unlocked >/dev/null 2>&1 && echo unlocked || echo locked)"

  local sock
  if sock="$(ssh_agent_socket)"; then
    echo "ssh agent:  ${sock}"
    SSH_AUTH_SOCK="${sock}" ssh-add -l 2>&1 | sed 's/^/            /'
  else
    echo "ssh agent:  not running (run 'rbw unlock')"
  fi
}

help () {
  cat <<EOF
$(basename "${0}") manages secrets kept out of this repository.

Usage:
  $(basename "${0}") <command>

Commands:
  setup              Configure rbw (email, server, pinentry, lock timeout)
  pull               Write ~/.ssh/config from the vault
  push               Store the current ~/.ssh/config in the vault
  authorize [host…]  Append the vault public key to each host's
                     authorized_keys. Without arguments, every non-wildcard
                     Host in ~/.ssh/config is used.
  status             Show rbw, vault and ssh-agent state
  help               Show this help

Environment:
  SSH_CONFIG_ITEM    Vault item holding the config (default: dotfiles-ssh-config)
  SSH_KEY_ITEM       Vault item holding the key (default: SSH)
  RBW_LOCK_TIMEOUT   Seconds before the master password is required again
                     (default: 300)
EOF
}

cmd="${1:-help}"
shift || true

case "${cmd}" in
  setup )     setup ;;
  pull )      pull ;;
  push )      push ;;
  authorize ) authorize "$@" ;;
  status )    status ;;
  help | --help | -h ) help ;;
  * ) err "Unknown command: ${cmd}"; help; exit 1 ;;
esac
