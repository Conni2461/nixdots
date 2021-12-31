{ config, pkgs, lib, fetchFromGitHub, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (_: {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "dwm";
          rev = "d890c400ccf24239107a53a47bf4244b9f97137e";
          sha256 = "sha256:0hdvda7yv156jyf45rm5k836s5myjwspbayz3igqkkzqd6aqkmwp";
        };
        buildInputs = with pkgs; [
          xorg.libX11
          xorg.libXinerama
          xorg.libXft
          xorg.libXext
        ];
      });
      dmenu = super.dmenu.overrideAttrs (_: {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "dmenu";
          rev = "517c0d23438278cef4fc1fc2c01705235bdffaef";
          sha256 = "sha256:1m16vyq71wkky2cjy8438izhri6yykh0wfxvdzr751srzaz6fi7i";
        };
      });
      st = super.st.overrideAttrs (_: {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "st";
          rev = "f1b17d129c75debb2090505e654396ec50335ed5";
          sha256 = "sha256:02ly9q8cjqm14sbv4nfwq67x7z8s940ycnasf7mgyzxk4v959dvj";
        };
      });
      slock = super.slock.overrideAttrs (_: {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "slock";
          rev = "bded8aa5889386c68ad9ab0b40f0ca7d905c3046";
          sha256 = "sha256:0ya0fiv7i8asb2r0qcqgrxyb0xm48lwbvqh14jx10mhv1g3ds493";
        };
        buildInputs = with pkgs; [
          xorg.libX11
          xorg.libXinerama
          xorg.libXext
          xorg.libXrandr
          xorg.xorgproto
          imlib2
        ];
      });
    })
  ];

  hardware.pulseaudio.enable = false;
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      layout = "de";
      xkbModel = "pc105";
      xkbVariant = "nodeadkeys";
      displayManager.lightdm.enable = true;
      displayManager.startx.enable = true;
      windowManager.dwm.enable = true;
      xkbOptions = "caps:escape";
    };
    ratbagd.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
  };
  security.rtkit.enable = true;

  virtualisation.docker.enable = true;

  users.users.conni = {
    createHome = true;
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
  };

  environment = {
    systemPackages = with pkgs; let
      unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
      rdq = writeShellScriptBin "rdq" ''
        #!/bin/sh
        # A dmenu binary prompt script.
        # Gives a dmenu prompt labeled with $1 to perform command $2.
        # For example:
        # ./prompt "Do you want to shutdown?" "shutdown -h now"

        prompt="$1"
        shift
        com="$1"
        shift

        [ $(printf "No\nYes" | dmenu -i -p "$prompt" "$@") = "Yes" ] && $com
      '';
    in
    [
      coreutils
      file
      gawk
      git
      lsof

      pciutils

      jq
      docker-compose

      binutils
      htop
      util-linux
      fd
      ripgrep
      skim
      exa
      delta
      bat
      R
      tig
      imagemagickBig
      grc

      ctags
      unstable.neovim

      # kbd
      tmux
      wget
      curl
      iproute2
      iputils

      bzip2
      gnutar
      gzip
      unzip
      xz
      zip

      ncdu
      nix-index

      go
      poetry
      black
      pyright
      unstable.insomnia

      gcc
      gnumake
      gdb
      clang-tools
      valgrind
      autoconf
      autoconf-archive

      unstable.rust-analyzer
      rnix-lsp

      nodejs
      yarn

      sqlite
      sqlitebrowser

      nixpkgs-fmt
      phpPackages.php-cs-fixer

      nodePackages.bash-language-server
      nodePackages.prettier
      nodePackages.vscode-css-languageserver-bin
      nodePackages.vscode-html-languageserver-bin
      nodePackages.vscode-json-languageserver
      nodePackages.typescript-language-server
      nodePackages.vim-language-server
      nodePackages.yaml-language-server
      unstable.nodePackages.intelephense
      shellcheck

      gnupg
      gopass

      unstable.discord
      steam
      firefox
      mpv
      obs-studio
      (pkgs.xfce.thunar.override { thunarPlugins = [ pkgs.xfce.thunar-archive-plugin ]; })
      xfce.xfconf
      gnome.adwaita-icon-theme
      zathura
      piper
      steam

      pulsemixer
      pavucontrol

      xdg-utils
      sxiv

      flameshot
      feh
      xclip
      arandr

      # nextcloud-client
      libreoffice
      thunderbird

      pulseaudio.out
      rdq
      dmenu
      st
      clipmenu
    ];
    extraInit = ''
      xset r rate 300 50
    '';
  };

  programs = {
    light.enable = true;
    slock.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "tty";
    };
    zsh = {
      enable = true;
      shellAliases = {
        ls = "ls -hNF --color=auto --group-directories-first";
        l = "exa -bghl -sname --group-directories-first";
        ll = "exa -bghla -sname --group-directories-first";
        tree = "exa -sname --tree";
        mkd = "mkdir -pv";
        cp = "cp -v";
        mv = "mv -v";
        rm = "rm -v";
        g = "git";
        v = "nvim";
        vim = "nvim";
        ".." = "cd ..";
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
    };
  };

  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "FiraCode Nerd Font Mono" ];
      };
    };
  };

  system.stateVersion = "21.11";
}
