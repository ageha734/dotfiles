# dotfile

## Get started

### 1. Clone dotfile

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/ageha734/dotfile.git
```

### 2. Setup proto

```bash
bash <(curl -fsSL https://moonrepo.dev/install/proto.sh)
```

### 3. 1Password CLI Authentication

```bash
op signin
```

### 4. Git Signing Key Auth Setup

```bash
git config --global user.signingkey $(op item get "GitHub SSH" --fields "public key")
```

## Setup Check

✅ **2025年08月01日** に動作確認済み
🔒 **2025年08月01日** にセキュリティ確認済み

<!-- last-check -->
