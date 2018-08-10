# Background
mkdir -p ~/Pictures/Background
wget https://i.imgur.com/MTakAux.jpg -O ~/Pictures/Background/background001.jpg

# Config files
mkdir -p ~/.config/termite
cp ./dotfiles/config/termite/config ~/.config/termite/config
cp ./dotfiles/xmonad/xmonad.hs ~/.xmonad/xmonad.hs
cp ./dotfiles/xmobarrc ~/.xmobarrc
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
