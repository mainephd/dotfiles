#!/usr/bin/env fish
# import.fish — Run on your NEW Mac to restore configuration
# Usage: fish ~/dotfiles-export/import.fish
#
# This script is bundled into dotfiles-export/ by export.fish.
# Transfer dotfiles-export/ to the new Mac first:
#   On old Mac:  tar czf ~/dotfiles-export.tar.gz -C ~ dotfiles-export
#   Transfer:    scp ~/dotfiles-export.tar.gz newmac:~/
#   On new Mac:  tar xzf ~/dotfiles-export.tar.gz -C ~
#                fish ~/dotfiles-export/import.fish

set -l IMPORT_DIR (dirname (status filename))

if not test -d $IMPORT_DIR
    echo "Error: Cannot find import directory"
    exit 1
end

echo "==> Importing configuration from $IMPORT_DIR"
echo "    Source machine manifest:"
cat $IMPORT_DIR/MANIFEST.txt 2>/dev/null | head -4
echo ""

# ─── Step 1: Install Homebrew ───
if not command -q brew
    echo "==> Installing Homebrew..."
    /bin/bash -c "(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "==> Homebrew already installed"
end

# ─── Step 2: Install Homebrew packages ───
if test -f $IMPORT_DIR/Brewfile
    echo "==> Installing Homebrew packages from Brewfile..."
    brew bundle install --file=$IMPORT_DIR/Brewfile
else
    echo "  !! No Brewfile found, skipping"
end

# ─── Step 3: Fish shell config ───
echo "==> Restoring Fish config..."
mkdir -p ~/.config/fish/{functions,completions,conf.d}

# Back up existing config if present
if test -f ~/.config/fish/config.fish
    cp ~/.config/fish/config.fish ~/.config/fish/config.fish.bak
    echo "  -> Backed up existing config.fish"
end

cp $IMPORT_DIR/fish/config.fish ~/.config/fish/config.fish
cp -R $IMPORT_DIR/fish/functions/ ~/.config/fish/functions/
cp -R $IMPORT_DIR/fish/completions/ ~/.config/fish/completions/
cp -R $IMPORT_DIR/fish/conf.d/ ~/.config/fish/conf.d/
cp $IMPORT_DIR/fish/fish_variables ~/.config/fish/fish_variables 2>/dev/null

# ─── Step 4: Starship config ───
echo "==> Restoring Starship config..."
mkdir -p ~/.config/fish/starship
test -f $IMPORT_DIR/starship/starship.toml
and cp $IMPORT_DIR/starship/starship.toml ~/.config/fish/starship/
test -f $IMPORT_DIR/starship/starship-default.toml
and cp $IMPORT_DIR/starship/starship-default.toml ~/.config/starship.toml

# ─── Step 5: GitHub CLI ───
echo "==> Restoring GitHub CLI config..."
mkdir -p ~/.config/gh
cp $IMPORT_DIR/gh/config.yml ~/.config/gh/
echo "  !! You'll need to re-authenticate: gh auth login"

# ─── Step 6: Goose config ───
if test -f $IMPORT_DIR/goose/config.yaml
    echo "==> Restoring Goose config..."
    mkdir -p ~/.config/goose
    cp $IMPORT_DIR/goose/config.yaml ~/.config/goose/
end

# ─── Step 7: Git config ───
if test -f $IMPORT_DIR/.gitconfig
    echo "==> Restoring Git config..."
    cp $IMPORT_DIR/.gitconfig ~/.gitconfig
end

# ─── Step 8: SSH config & public keys ───
echo "==> Restoring SSH config..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
if test -d $IMPORT_DIR/ssh
    for f in $IMPORT_DIR/ssh/*.pub
        cp $f ~/.ssh/
    end
    test -f $IMPORT_DIR/ssh/config; and cp $IMPORT_DIR/ssh/config ~/.ssh/config
    chmod 644 ~/.ssh/*.pub 2>/dev/null
    chmod 600 ~/.ssh/config 2>/dev/null
end
echo "  !! Private keys must be transferred separately or regenerated"

# ─── Step 9: VS Code extensions ───
if test -f $IMPORT_DIR/vscode-extensions.txt; and command -q code
    echo "==> Installing VS Code extensions..."
    for ext in (cat $IMPORT_DIR/vscode-extensions.txt)
        code --install-extension $ext --force 2>/dev/null
    end
end

# ─── Step 10: VS Code settings ───
if test -d $IMPORT_DIR/vscode
    echo "==> Restoring VS Code settings..."
    set -l vscode_dir "$HOME/Library/Application Support/Code/User"
    mkdir -p "$vscode_dir"
    test -f $IMPORT_DIR/vscode/settings.json
    and cp $IMPORT_DIR/vscode/settings.json "$vscode_dir/"
    test -f $IMPORT_DIR/vscode/keybindings.json
    and cp $IMPORT_DIR/vscode/keybindings.json "$vscode_dir/"
end

# ─── Step 11: Google Cloud SDK ───
echo "==> Google Cloud SDK..."
if not test -d ~/google-cloud-sdk
    echo "  !! Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
    echo "  !! Then run: gcloud init"
else
    echo "  -> Already installed"
    if test -f $IMPORT_DIR/gcloud/config_default
        mkdir -p ~/.config/gcloud/configurations
        cp $IMPORT_DIR/gcloud/config_default ~/.config/gcloud/configurations/
    end
end

# ─── Step 12: Clone dotfiles repo (Nix configs) ───
echo "==> Cloning dotfiles repo..."
if not test -d ~/src.github/dotfiles
    mkdir -p ~/src.github
    git clone https://github.com/mainephd/dotfiles.git ~/src.github/dotfiles
else
    echo "  -> Already cloned"
end

# ─── Summary ───
echo ""
echo "============================================"
echo "  Import complete! Manual steps remaining:"
echo "============================================"
echo ""
echo "  1. Transfer SSH private keys from old machine"
echo "     scp oldmac:~/.ssh/id_* ~/.ssh/"
echo ""
echo "  2. Re-authenticate GitHub CLI"
echo "     gh auth login"
echo ""
echo "  3. Re-authenticate Google Cloud"
echo "     gcloud auth login"
echo "     gcloud auth application-default login"
echo ""
echo "  4. Install Rancher Desktop (if needed)"
echo "     https://rancherdesktop.io/"
echo ""
echo "  5. (Optional) Apply Nix configs"
echo "     darwin-rebuild switch --flake ~/src.github/dotfiles/.#work-laptop"
echo "     home-manager switch --flake ~/src.github/dotfiles/.#jermaine@work-laptop"
echo ""
echo "  6. Set up 1Password SSH agent"
echo "     https://developer.1password.com/docs/ssh/"
echo ""
echo "  7. Restart your terminal"
echo ""
