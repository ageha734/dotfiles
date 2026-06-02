# dotfiles

## Get started

### 1. Install dotfiles

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ageha734/dotfiles
```

### 2. Manual setup

#### 1Password

```bash
# Authenticate 1Password CLI
op signin

# Set git signing key
git config --global user.signingkey "$(op item get 'GitHub SSH' --fields 'public key')"
```

#### Apple ID

Sign in with Apple ID if you need Mac App Store apps.

#### macOS settings

Some settings require a re-login or reboot to take effect.

## What's managed

| Category       | Method                                       |
| -------------- | -------------------------------------------- |
| Packages       | `brew bundle` (`.chezmoidata/packages.yaml`) |
| Dotfiles       | chezmoi                                      |
| Fish plugins   | fisher                                       |
| Runtimes       | proto                                        |
| Tmux plugins   | tpm                                          |
| Java/Kotlin    | SDKMAN                                       |
| macOS settings | `defaults write`                             |
| Cursor exts    | `cursor --install-extension`                 |
| External deps  | `.chezmoiexternal.toml`                      |

## Setup Check

<!-- last-check-start -->
<!-- last-check-end -->
