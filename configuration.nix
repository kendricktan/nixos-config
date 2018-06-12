# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running â€˜nixos-helpâ€™).


{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use EFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelModules = [ "pkgs.linuxPackages.nvidia_x11" ];

  networking.networkmanager.enable = true;
  networking.hostName = "nixos-t460s"; # Define your hostname.

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
      rofi dmenu trayer # Dynamic menu
      pavucontrol pasystray # Volume
      networkmanager networkmanagerapplet # Network
      paper-icon-theme paper-gtk-theme
      xorg.xcursorthemes lxappearance
      i3lock-fancy # Lock screen

      # CLI utils
      curl wget
      git gparted
      htop neofetch nox
      gnupg powertop scrot
      telnet tree
      xorg.xev xorg.xkill

      # File managers, compression tools, file-related tools
      gnome3.nautilus p7zip unrar unzip
      samba gvfs xfce.thunar # Thunar in-case nautilus screws up
      librsvg ntfs3g

      # Dev-tools
      gnumake gcc
      cabal-install
      haskell.packages.ghc802.hdevtools
      haskell.packages.ghc802.stylish-haskell
      haskell.packages.ghc802.hoogle

      # Dev-languages
      python36
      haskell.packages.ghc802.ghc

      # Browsers
      firefox google-chrome

      # Editors
      gnome3.gedit
      neovim vscode

      # Terminals, shells and shell goodies
      termite tmux
      oh-my-zsh zsh

      # Torrent, multimedia, chat, cloud
      qbittorrent gnome3.gnome-screenshot
      vlc feh
      hexchat slack
      dropbox mirage
      rambox imagemagick

      # Finance
      haskellPackages.hledger
      haskellPackages.hledger-web

      # Key management
      keepass gnome3.seahorse

      # Office
      libreoffice zathura
      evince

      # System management
      xlibs.xmodmap xlibs.xbacklight
      upower tlp acpi

      # Libraries
      python36Packages.neovim
      python36Packages.youtube-dl
      python36Packages.pip

      # CUDA
      # cudatoolkit
    ];
    # GTK Icons
    sessionVariables = {
      GTK_DATA_PREFIX = [
        "${config.system.path}"
      ];
      GDK_PIXBUF_MODULE_FILE = "$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)";
    };

    # GVFS for mounting network drives
    variables.GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];

    # Trackpoint
    etc = {
      "X11/xorg.conf.d/20-thinkpad.conf".text = ''
        Section "InputClass"
          Identifier  "Trackpoint Wheel Emulation"
          MatchProduct  "TPPS/2 IBM TrackPoint|DualPoint Stick|Synaptics Inc. Composite TouchPad / TrackPoint|ThinkPad USB Keyboard with TrackPoint|USB Trackpoint pointing device|Composite TouchPad / TrackPoint"
          MatchDevicePath "/dev/input/event*"
          Option    "EmulateWheel"    "true"
          Option    "EmulateWheelButton"  "2"
          Option    "Emulate3Buttons" "false"
          Option    "XAxisMapping"    "6 7"
          Option    "YAxisMapping"    "4 5"
        EndSection
      '';
    };
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
      # SSH-Agent
      if [ ! -S ~/.ssh/ssh_auth_sock ]; then
        eval `ssh-agent` &> /dev/null
        ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
      fi
      export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
      grep -slR "PRIVATE" ~/.ssh/ | xargs ssh-add -t 24h &> /dev/null

      # z - jump around
      source ${pkgs.fetchurl {url = "https://github.com/rupa/z/raw/2ebe419ae18316c5597dd5fb84b5d8595ff1dde9/z.sh"; sha256 = "0ywpgk3ksjq7g30bqbhl9znz3jh6jfg8lxnbdbaiipzgsy41vi10";}}

      # Oh my zsh
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      export ZSH_THEME="lambda"

      plugins=(git)

      source $ZSH/oh-my-zsh.sh
    '';
    promptInit = "";
  };

  # List services that you want to enable:
  services.samba.enable = true;
  services.gnome3.gnome-keyring.enable = true;
  services.upower.enable = true;
  services.acpid.enable = true;
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

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
    synaptics = {
      enable = true;
      minSpeed = "1.0";
      maxSpeed = "2.0";
      twoFingerScroll = true;
      palmDetect = true;
      tapButtons = false;
      scrollDelta = -75; # Natural scroll
    };
    # CUDA Related Stuff
    # videoDrivers = [ "nvidia" ];
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
      xfce = pkgs.xfce // {
        gvfs = pkgs.gvfs;
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
