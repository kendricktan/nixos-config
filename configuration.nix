# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running â€˜nixos-helpâ€™).


{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  networking.networkmanager.enable = true;
  networking.hostName = "kendrick-t460s"; # Define your hostname.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Australia/Brisbane";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      # WM / DM tools
      haskellPackages.xmobar
      stalonetray rofi dmenu
      pavucontrol pasystray # Volume
      networkmanager.out
      networkmanager networkmanagerapplet # Network
      i3lock-fancy

      # CLI utils
      curl wget
      git gparted
      htop neofetch nox
      gnupg powertop scrot
      telnet tree
      xorg.xev xorg.xkill

      # File managers, compression tools, file-related tools
      nitrogen gnome3.nautilus
      p7zip unrar unzip

      # Dev-tools
      cabal-install
      haskell.packages.ghc802.hdevtools
      haskell.packages.ghc802.stylish-haskell
      haskell.packages.ghc802.hoogle

      # Dev-languages
      python36

      # Browsers
      firefox google-chrome

      # Editors
      gnome3.gedit
      neovim vscode

      # Terminals, shells and shell goodies
      termite tmux
      oh-my-zsh zsh

      # Torrent, multimedia, chat, cloud
      qbittorrent
      vlc feh
      hexchat slack
      dropbox

      # Finance
      haskellPackages.hledger
      haskellPackages.hledger-web

      # Key management
      keepass gpa

      # Office
      libreoffice

      # System management
      xlibs.xmodmap xlibs.xbacklight
      upower

      # Libraries
      python36Packages.neovim
      python36Packages.youtube-dl
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  programs.slock.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      code = "vscode";
    };
    enableCompletion = true;
    enableAutosuggestions = true;
    interactiveShellInit = ''
      # z - jump around
      source ${pkgs.fetchurl {url = "https://github.com/rupa/z/raw/2ebe419ae18316c5597dd5fb84b5d8595ff1dde9/z.sh"; sha256 = "0ywpgk3ksjq7g30bqbhl9znz3jh6jfg8lxnbdbaiipzgsy41vi10";}}

      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      export ZSH_THEME="lambda"

      plugins=(git)

      source $ZSH/oh-my-zsh.sh
    '';
    promptInit = "";
  };

  # List services that you want to enable:
  services.gnome3.gnome-keyring.enable = true;
  services.upower.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = hpkgs: [
        hpkgs.xmobar
        hpkgs.xmonad-contrib
        hpkgs.xmonad-extras
      ];
    };
    windowManager.default = "xmonad";
    displayManager.sessionCommands = with pkgs; lib.mkAfter
    ''
    # Swap caps lock and escape
    xmodmap -e "keycode 9 = Caps_Lock NoSymbol Caps_Lock"
    xmodmap -e "keycode 66 = Escape NoSymbol Escape"
    xmodmap -e "clear Lock"
    '';
  };

  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    fonts = with pkgs; [
      corefonts		  # Microsoft free fonts
      fira	      	  # Monospace
      inconsolata     	  # Monospace
      powerline-fonts
      ubuntu_font_family
      unifont		  # International languages
    ];
  };

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    extraUsers.kendrick = {
      isNormalUser = true;
      home = "/home/kendrick";
      description = "Kendrick Tan";
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
    };
  };

  # Allow unfree build
  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: rec {
      neovim = (import ./neovim.nix);
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
