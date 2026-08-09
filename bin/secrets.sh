#!/bin/bash
# Manage secrets that must not live in this (public) repository.
#
# SSH keys are stored in Bitwarden as "SSH key" items and served by rbw-agent,
# so no private key is ever written to disk. The ssh config is stored as a
# secure note because it carries hostnames and account names.
set -euo pipefail

SSH_CONFIG_ITEM="${SSH_CONFIG_ITEM:-dotfiles-ssh-config}"
SSH_CONFIG_PATH="${HOME}/.ssh/config"
LOCK_TIMEOUT="${RBW_LOCK_TIMEOUT:-300}"

# shell-logger.sh is deliberately not used here: its err() returns 100, which
# would abort the script under set -e before the message is acted on.
info ()   { printf '\033[0;32m[INFO]\033[0m %s\n' "$*"; }
notice () { printf '\033[0;34m[NOTICE]\033[0m %s\n' "$*"; }
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

default_pinentry () {
  case "$(uname -s)" in
    Darwin*) command -v pinentry-mac >/dev/null 2>&1 && { echo pinentry-mac; return; } ;;
  esac
  command -v pinentry >/dev/null 2>&1 && { echo pinentry; return; }
  echo pinentry-curses
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

  if ! rbw get "${SSH_CONFIG_ITEM}" --field notes > "${tmp}"; then
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

push () {
  require_configured

  if [ ! -f "${SSH_CONFIG_PATH}" ]; then
    err "${SSH_CONFIG_PATH} does not exist."
    exit 1
  fi

  # rbw add/edit opens $EDITOR on a temp file and treats the first line as the
  # password, so prepend a blank line to keep the config intact in the notes.
  local editor tmp
  editor="$(mktemp)"
  tmp="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm -f '${editor}' '${tmp}'" EXIT

  { echo; cat "${SSH_CONFIG_PATH}"; } > "${tmp}"

  cat > "${editor}" <<EOF
#!/bin/sh
cat "${tmp}" > "\$1"
EOF
  chmod +x "${editor}"

  if rbw get "${SSH_CONFIG_ITEM}" >/dev/null 2>&1; then
    EDITOR="${editor}" VISUAL="${editor}" rbw edit "${SSH_CONFIG_ITEM}"
    info "Updated '${SSH_CONFIG_ITEM}' in the vault."
  else
    EDITOR="${editor}" VISUAL="${editor}" rbw add "${SSH_CONFIG_ITEM}"
    info "Created '${SSH_CONFIG_ITEM}' in the vault."
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
  setup     Configure rbw (email, server, pinentry, lock timeout)
  pull      Write ~/.ssh/config from the vault
  push      Store the current ~/.ssh/config in the vault
  status    Show rbw, vault and ssh-agent state
  help      Show this help

Environment:
  SSH_CONFIG_ITEM    Vault item name (default: dotfiles-ssh-config)
  RBW_LOCK_TIMEOUT   Seconds before the master password is required again
                     (default: 300)
EOF
}

case "${1:-help}" in
  setup )  setup ;;
  pull )   pull ;;
  push )   push ;;
  status ) status ;;
  help | --help | -h ) help ;;
  * ) err "Unknown command: ${1}"; help; exit 1 ;;
esac
