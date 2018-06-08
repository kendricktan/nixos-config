# nixos-config
NixOS 18.03 config files


# Getting started

```
# copy *.nix files into /etc/nixos/*
nixos-rebuild switch
```

# Getting stuff working
1. `cp /etc/zshrc ~/.zshrc`
2. `vim ~/.zshrc`
3. Delete first 3 non-comment lines.
4.
```bash
mkdir -p ~/.config/termite
mkdir -p ~/.config/taffybar
cp nixos-config/xmonad/xmonad.hs ~/.xmonad.hs
cp -r nixos-config/dotfiles/config/taffybar/* ~/.config/taffybar/
cp -r nixos-config/dotfiles/config/termite/* ~/.config/termite/
```
