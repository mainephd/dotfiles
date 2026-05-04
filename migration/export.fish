#!/usr/bin/env fish
# export.fish — Run on your CURRENT Mac to capture state
# Usage: fish ~/.config/migration/export.fish

set -l EXPORT_DIR ~/dotfiles-export
mkdir -p $EXPORT_DIR

echo "==> Exporting current Mac configuration to $EXPORT_DIR"

# 1. Homebrew bundle (captures all formulae, casks, taps, and Mac App Store apps)
echo "  -> Homebrew packages..."
brew bundle dump --file=$EXPORT_DIR/Brewfile --force --describe

# 2. Fish shell config
echo "  -> Fish config..."
mkdir -p $EXPORT_DIR/fish
cp -R ~/.config/fish/config.fish $EXPORT_DIR/fish/
cp -R ~/.config/fish/functions/ $EXPORT_DIR/fish/functions/
cp -R ~/.config/fish/completions/ $EXPORT_DIR/fish/completions/
cp -R ~/.config/fish/conf.d/ $EXPORT_DIR/fish/conf.d/
cp -R ~/.config/fish/fish_variables $EXPORT_DIR/fish/

# 3. Starship config
echo "  -> Starship config..."
mkdir -p $EXPORT_DIR/starship
cp ~/.config/fish/starship/starship.toml $EXPORT_DIR/starship/
# Also check the default location
test -f ~/.config/starship.toml; and cp ~/.config/starship.toml $EXPORT_DIR/starship/starship-default.toml

# 4. GitHub CLI config (no tokens — those need re-auth)
echo "  -> GitHub CLI config..."
mkdir -p $EXPORT_DIR/gh
cp ~/.config/gh/config.yml $EXPORT_DIR/gh/

# 5. Goose config
echo "  -> Goose config..."
mkdir -p $EXPORT_DIR/goose
cp ~/.config/goose/config.yaml $EXPORT_DIR/goose/

# 6. Git global config
echo "  -> Git config..."
test -f ~/.gitconfig; and cp ~/.gitconfig $EXPORT_DIR/
git config --global --list > $EXPORT_DIR/gitconfig-dump.txt 2>/dev/null

# 7. SSH public keys (never export private keys!)
echo "  -> SSH public keys..."
mkdir -p $EXPORT_DIR/ssh
cp ~/.ssh/*.pub $EXPORT_DIR/ssh/ 2>/dev/null
test -f ~/.ssh/config; and cp ~/.ssh/config $EXPORT_DIR/ssh/

# 8. VS Code extensions list
echo "  -> VS Code extensions..."
code --list-extensions > $EXPORT_DIR/vscode-extensions.txt 2>/dev/null

# 9. VS Code settings
echo "  -> VS Code settings..."
mkdir -p $EXPORT_DIR/vscode
set -l vscode_settings "$HOME/Library/Application Support/Code/User/settings.json"
test -f "$vscode_settings"; and cp "$vscode_settings" $EXPORT_DIR/vscode/
set -l vscode_keybindings "$HOME/Library/Application Support/Code/User/keybindings.json"
test -f "$vscode_keybindings"; and cp "$vscode_keybindings" $EXPORT_DIR/vscode/

# 10. macOS defaults (dock, finder, keyboard, etc.)
echo "  -> macOS preferences..."
defaults read com.apple.dock > $EXPORT_DIR/macos-dock.plist 2>/dev/null
defaults read com.apple.finder > $EXPORT_DIR/macos-finder.plist 2>/dev/null
defaults read NSGlobalDomain > $EXPORT_DIR/macos-global.plist 2>/dev/null

# 11. Nix dotfiles repo reference
echo "  -> Nix dotfiles reference..."
echo "https://github.com/mainephd/dotfiles" > $EXPORT_DIR/dotfiles-repo.txt

# 12. Rancher Desktop config (if exists)
echo "  -> Rancher Desktop..."
test -d ~/.rd; and echo "Rancher Desktop is installed" > $EXPORT_DIR/rancher-desktop.txt

# 13. Google Cloud SDK config (no credentials!)
echo "  -> gcloud config..."
mkdir -p $EXPORT_DIR/gcloud
test -f ~/.config/gcloud/configurations/config_default
and cp ~/.config/gcloud/configurations/config_default $EXPORT_DIR/gcloud/

# 14. Installed command-line tools inventory
echo "  -> CLI tools inventory..."
which terraform go kubectl helm starship fish node python3 gcloud docker 2>/dev/null > $EXPORT_DIR/cli-tools.txt

# 15. Create manifest
echo "  -> Creating manifest..."
echo "Export date: "(date) > $EXPORT_DIR/MANIFEST.txt
echo "Hostname: "(hostname) >> $EXPORT_DIR/MANIFEST.txt
echo "macOS: "(sw_vers -productVersion) >> $EXPORT_DIR/MANIFEST.txt
echo "Arch: "(uname -m) >> $EXPORT_DIR/MANIFEST.txt
echo "" >> $EXPORT_DIR/MANIFEST.txt
echo "Contents:" >> $EXPORT_DIR/MANIFEST.txt
find $EXPORT_DIR -type f | sort >> $EXPORT_DIR/MANIFEST.txt

echo ""
echo "==> Export complete! Files are in $EXPORT_DIR"
echo "    Transfer this directory to your new Mac, then run import.fish"
echo ""
echo "    To transfer: tar czf ~/dotfiles-export.tar.gz -C ~ dotfiles-export"
