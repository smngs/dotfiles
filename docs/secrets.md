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
$ make install          # installs rbw and pinentry
$ make secrets-setup    # asks for the vault email and server URL
$ rbw login
$ rbw unlock            # starts rbw-agent, which is also the SSH agent
$ make secrets          # writes ~/.ssh/config
```

`make secrets-setup` sets `pinentry-mac` on macOS and `pinentry` elsewhere, and
a `lock_timeout` of 300 seconds. Shorten it to be asked for the master password
more often:

```
$ RBW_LOCK_TIMEOUT=60 make secrets-setup
```

## Registering an SSH key

Create the key **inside Bitwarden** (Web vault or desktop: new item -> SSH key ->
generate). The private key is then never on any disk to begin with.

```
$ rbw sync
$ rbw unlock
$ ssh-add -l             # the key should be listed
```

To import an existing key instead, paste it into a new `SSH key` item and remove
the local copy afterwards.

## Storing the ssh config

```
$ make secrets-push      # ~/.ssh/config -> vault
$ make secrets           # vault -> ~/.ssh/config
```

`push` prepends a blank line because `rbw add` treats the first line of the
buffer as the password; the config itself lives in the note body.

## How the shell picks up the agent

`.zshrc.lazy` exports `SSH_AUTH_SOCK` when the rbw socket exists, probing both
`$XDG_RUNTIME_DIR/rbw/` and the temp-dir fallback used on macOS. While the agent
is not running the system agent stays in place, so nothing breaks.

## YubiKey

`Host *` still sets `PKCS11Provider`, so a YubiKey keeps working independently
of the agent: OpenSSH tries the PKCS#11 token and the agent both. Keep the
YubiKey as the primary factor and treat the vault as the fallback for machines
without it.

## Checking state

```
$ bash bin/secrets.sh status
rbw:        rbw 1.15.0
pinentry:   pinentry-mac
vault:      locked
ssh agent:  not running (run 'rbw unlock')
```
