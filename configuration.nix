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
      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "dwm";
          rev = "60c5d4c54a0a5c1b962150ffdb2a5e36ee7a5e58";
          sha256 = "sha256:1f4czbq5x9fnds0xx5j9wah8aivv3xkz76vsk6wa30i5ggcficw3";
        };
        buildInputs = with pkgs; oldAttrs.buildInputs ++ [ xorg.libXext ];
      });
      dmenu = super.dmenu.overrideAttrs (_: {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "dmenu";
          rev = "517c0d23438278cef4fc1fc2c01705235bdffaef";
          sha256 = "sha256:1m16vyq71wkky2cjy8438izhri6yykh0wfxvdzr751srzaz6fi7i";
        };
      });
      st = super.st.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "st";
          rev = "7db3c660abe124ac50cd3c5cc2a1dc5fd28cd14e";
          sha256 = "sha256:0ryg69mvwdnc634c6ysv58rca1qm2q1k77h59vvymbk65fiyrjzs";
        };
        buildInputs = with pkgs; oldAttrs.buildInputs ++ [ harfbuzz ];
      });
      slock = super.slock.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "slock";
          rev = "bded8aa5889386c68ad9ab0b40f0ca7d905c3046";
          sha256 = "sha256:0ya0fiv7i8asb2r0qcqgrxyb0xm48lwbvqh14jx10mhv1g3ds493";
        };
        buildInputs = with pkgs; oldAttrs.buildInputs ++ [
          xorg.libXinerama
          imlib2
        ];
      });
    })
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    setLdLibraryPath = true;
    driSupport32Bit = true;
  };
  hardware.pulseaudio.enable = false;
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      layout = "de";
      xkbModel = "pc105";
      xkbVariant = "nodeadkeys";
      displayManager.lightdm.enable = true;
      displayManager.defaultSession = "none+dwm";
      displayManager.startx.enable = true;
      windowManager.dwm.enable = true;
      desktopManager.plasma5.enable = true;
      xkbOptions = "caps:escape";
      serverLayoutSection = ''
        Option         "Xinerama" "0"
      '';
      screenSection = ''
        Option         "nvidiaXineramaInfoOrder" "DFP-1"
        Option         "metamodes" "HDMI-0: 1920x1080 +0+360 {ForceCompositionPipeline=On}, DP-0: 2560x1440 +1920+0 {ForceCompositionPipeline=On}"
        Option         "AllowIndirectGLXProtocol" "off"
      '';
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
  systemd.services.display-manager.restartIfChanged = false;

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
      dunst
      libnotify

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
      # unstable.neovim
      neovim-nightly

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

      texlive.combined.scheme-medium
      texlab

      go
      unstable.insomnia

      (python3.withPackages (ps: with ps; [
        flake8
        pylint
        ipython
        requests
        compiledb
      ]))
      poetry
      black
      pyright

      gcc
      gnumake
      gdb
      clang
      clang-tools
      llvm
      valgrind
      autoconf
      autoconf-archive

      unstable.rustc
      unstable.rustfmt
      unstable.cargo
      cargo-watch
      clippy
      unstable.rust-analyzer
      rnix-lsp

      nodejs
      yarn
      nodePackages.node2nix

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
      firefox
      spotify
      playerctl
      mpv
      obs-studio
      (pkgs.xfce.thunar.override { thunarPlugins = [ pkgs.xfce.thunar-archive-plugin ]; })
      xfce.xfconf
      gnome.adwaita-icon-theme
      zathura
      piper
      newsboat

      pulsemixer
      pavucontrol

      xdg-utils
      sxiv

      flameshot
      feh
      xclip
      numlockx
      arandr

      # nextcloud-client
      libreoffice
      thunderbird

      neomutt
      mutt-wizard
      isync
      msmtp
      pass

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
    steam.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "tty";
    };
    ssh.startAgent = true;
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
    enableDefaultFonts = true;
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
