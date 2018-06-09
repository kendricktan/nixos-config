# nixos-config
NixOS 18.03 config files


# Getting started

```
# copy *.nix files into /etc/nixos/*
nixos-rebuild switch
```

# Getting stuff working
1. Download wallpaper
```
mkdir ~/Pictures/Background
wget https://i.imgur.com/MTakAux.jpg -O ~/Pictures/Background/background001.jpg
```
2. `cp /etc/zshrc ~/.zshrc`
3. `vim ~/.zshrc`
4. Delete first 3 non-comment lines. (The first if statement)
5.
```bash
mkdir -p ~/.config/termite
cp nixos-config/dotfiles/xmonad/xmonad.hs ~/.xmonad.hs
cp nixos-config/dotfiles/xmobarrc ~/.xmobarrc
cp nixos-config/dotfiles/stalonetrayrc ~/.stalonetrayrc
```
6. Update dropbox
```
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
```
