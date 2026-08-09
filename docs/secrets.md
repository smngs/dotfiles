Secrets
===

This repository is public, so hostnames, account names and keys are kept in
Bitwarden instead. [rbw](https://github.com/doy/rbw) reads them and doubles as
an SSH agent, so **no private key is ever written to disk** and no desktop app
is required. It is packaged for both macOS (Homebrew) and Arch (`extra/rbw`).

| What | Where | How it is used |
| --- | --- | --- |
| SSH private/public keys | Bitwarden `SSH key` items | Served by `rbw-agent` over `$SSH_AUTH_SOCK` |
| `~/.ssh/config` | Bitwarden secure note `dotfiles-ssh-config` | `make secrets` writes it into place |

## First run

```
$ make install          # installs rbw, bw and pinentry
$ make secrets-setup    # asks for the vault email and server URL
$ rbw login
$ rbw unlock            # starts rbw-agent, which is also the SSH agent
$ make secrets          # writes ~/.ssh/config
```

## Registering an SSH key

Create the key **inside Bitwarden** (web vault: new item -> SSH key -> generate).
The private key is then never on any disk to begin with. Bitwarden only
generates ED25519 keys.

```
$ rbw sync
$ ssh-add -l                                    # the key should be listed
$ bash bin/secrets.sh authorize                 # append it to every host in the config
$ bash bin/secrets.sh authorize <host>...       # or just these hosts
```

`authorize` matches on the key body, ignoring the trailing comment, so it is
safe to re-run. It verifies each host with a fresh connection afterwards —
reusing a live ControlMaster would report success even when the key was never
accepted. GitHub and similar hosts are skipped; register there through the web
UI with `rbw get 'SSH' --field public_key`.

## Storing the ssh config

```
$ make secrets           # vault -> ~/.ssh/config
$ make secrets-push      # ~/.ssh/config -> vault
```

**`push` needs the official `bw` CLI**, which keeps credentials separately from
rbw: the vault can be unlocked in rbw while `bw` is not even logged in. Run
`bw login <email>` once from a normal terminal if that happens.

rbw cannot write items non-interactively — `rbw add` waits on `$EDITOR` and
never returns without a tty — so writes go through `bw` and its JSON interface.
Reads stay on rbw. `push` reads the item back afterwards to prove the write
landed; an earlier version reported success while storing nothing.

## How the shell picks up the agent

`.zshrc.lazy` exports `SSH_AUTH_SOCK` when the rbw socket exists, probing both
`$XDG_RUNTIME_DIR/rbw/` and the temp-dir fallback used on macOS. It also links
the socket to `~/.local/share/ssh/rbw-agent.sock`, a stable path for tools that
do not read the shell config — `~/.claude/settings.json` points `SSH_AUTH_SOCK`
there so Claude Code can reach the agent.

`ssh`, `scp` and `sftp` are wrapped: a locked vault leaves the agent with no
keys and ssh only reports `Permission denied (publickey)`, so exit code 255
triggers `rbw unlock` and one retry. Other exit codes, including a remote
command's own status, pass through untouched.

## YubiKey

`PKCS11Provider` now sits behind a `Match exec` that probes for a plugged-in
YubiKey, because OpenSC otherwise prompts for a PIN on every connection. The
probe costs about 5ms. The condition is macOS-only (`ioreg`); Linux needs its
own rule if a YubiKey is used there.

Keep the YubiKey as the fallback: it is the only way into the hosts if the
vault becomes unavailable, and `mine-313.com` hosts the vault itself.

## Checking state

```
$ bash bin/secrets.sh status
rbw:        rbw 1.15.0
pinentry:   pinentry-mac
vault:      unlocked
ssh agent:  /var/folders/.../rbw-501/ssh-agent-socket
            256 SHA256:... (ED25519)
```
