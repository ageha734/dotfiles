# dotfiles

## Get started

### 1. Install dotfiles

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ageha734/dotfiles
```

自動的に以下がセットアップされます:

- Homebrew + 全パッケージ/cask/フォント
- fish シェル + fisher プラグイン
- proto ツールチェーン (Go, Node, Rust, Terraform, kubectl など)
- tmux + プラグイン (tpm)
- SDKMAN (Java, Kotlin)
- bat テーマ
- Cursor 拡張機能
- macOS システム設定 (Dock, Finder, キーボード等)

### 2. 手動セットアップ

#### 1Password

1Password にログインし、SSH agent を有効化する。

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
| fish プラグイン | fisher (`fish_plugins`) |
| ランタイム | proto (`.prototools`) |
| tmux プラグイン | tpm |
| Java/Kotlin | SDKMAN |
| macOS 設定 | `defaults write` |
| Cursor 拡張 | `cursor --install-extension` |
| 外部リソース | `.chezmoiexternal.toml` (bat テーマ, tpm) |

## CI

`compose.ci.yaml` で以下の lint/security チェックを実行:

actionlint, zizmor, shellcheck, shfmt, dprint, yamllint, fish-lint,
taplo, semgrep, trivy, gitleaks, trufflehog, detect-secrets,
supply-chain, permissions-check

## Setup Check

<!-- last-check-start -->
<!-- last-check-end -->
