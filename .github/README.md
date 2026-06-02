# dotfiles

## Get started

### 1. Install dotfiles

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ageha734/dotfiles
```

### 2. 手動セットアップ

#### 1Password

```bash
# 1Password CLI 認証
op signin

# Git 署名鍵を設定
git config --global user.signingkey "$(op item get 'GitHub SSH' --fields 'public key')"
```

#### Apple ID

Mac App Store アプリが必要な場合は Apple ID でログインする。

#### macOS 設定の反映

一部の設定は再ログインまたは再起動後に反映される。

## 管理対象

| カテゴリ | 方法 |
| -------- | ---- |
| パッケージ | `brew bundle` (`.chezmoidata/packages.yaml`) |
| dotfiles | chezmoi |
| fish プラグイン | fisher |
| ランタイム | proto |
| tmux プラグイン | tpm |
| Java/Kotlin | SDKMAN |
| macOS 設定 | `defaults write` |
| Cursor 拡張 | `cursor --install-extension` |
| 外部リソース | `.chezmoiexternal.toml` |

## Setup Check

<!-- last-check-start -->
<!-- last-check-end -->
