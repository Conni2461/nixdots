{ config, pkgs, lib, fetchFromGitHub, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia.nix
      ./pipewire.nix
      ./dwm.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      }))
    ];
  };

  services = {
    xserver = {
      enable = true;
      desktopManager.plasma5.enable = true;
    };
    ratbagd.enable = true;
  };

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

      unstable.gcc
      gnumake
      unstable.cmake
      gdb
      unstable.clang
      unstable.clang-tools
      unstable.llvm
      unstable.valgrind
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
    ];
    extraInit = ''
      xset r rate 300 50
    '';
  };

  programs = {
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
