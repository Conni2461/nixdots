{ config, pkgs, lib, fetchFromGitHub, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./uefi.nix
      ./nvidia.nix
      ./bluetooth.nix
      ./pipewire.nix
      ./dwm.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [
    config.boot.kernelPackages.rtl88x2bu
  ];

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
    xserver.enable = true;
    gnome.gnome-keyring.enable = true;
    ratbagd.enable = true;
  };

  virtualisation.docker.enable = true;

  users.users.conni = {
    createHome = true;
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
  };

  environment.systemPackages = with pkgs; let
    unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
    pfirefox = writeShellScriptBin "pfirefox" ''
      firefox --private-window
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
    unstable.vim
    neovim-nightly
    luajit
    luajitPackages.luacheck
    unstable.stylua
    sumneko-lua-language-server

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

    texlive.combined.scheme-full
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

    gcc11
    man-pages
    man-pages-posix
    gnumake
    unstable.cmake
    gdb
    clang_13
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
    pfirefox
    spotify
    playerctl
    mpv
    obs-studio
    (pkgs.xfce.thunar.override { thunarPlugins = [ pkgs.xfce.thunar-archive-plugin ]; })
    xfce.xfconf
    gnome.adwaita-icon-theme
    zathura
    piper

    xdg-utils
    sxiv

    flameshot
    feh
    xclip
    numlockx
    arandr

    nextcloud-client

    neomutt
    mutt-wizard
    notmuch
    isync
    msmtp
    pass
    lynx
  ];

  documentation = {
    dev.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
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
        grep = "grep --color=auto";
        diff = "diff --color=auto";
        mkd = "mkdir -pv";
        cp = "cp -v";
        mv = "mv -v";
        rm = "rm -v";
        type = "type -a";
        ka = "killall";
        df = "df -kHT";
        del = "trash";
        g = "git";
        e = "nvim";
        v = "nvim";
        vim = "nvim";
        mutt = "neomutt";
        z = "zathura";
        x = "sxiv -ft *";
        sdn = "sudo shutdown -h now";
        ccat = "highlight --out-format=ansi --force";
        yt = "youtube-dl --add-metadata -i -o '%(upload_date)s-%(title)s.%(ext)s'";
        yta = "yt -x -f bestaudio/best";
        lsp = "pacman -Qett --color=always | less";
        ffmpeg = "ffmpeg -hide_banner";
        d = "docker";
        dps = "docker ps";
        dm = "docker-machine";
        dcu = "docker compose up --build";
        dcd = "docker compose down";
        dcb = "docker compose build";
        ru = "docker run -ti --rm ubuntu:latest /bin/bash";
        ra = "docker run -ti --rm archlinux:latest /bin/bash";
        R = "R -q --save";
        wget = "wget --hsts-file ~/.cache/wget-hsts";
        tty-clock = "tty-clock -sct";
        khal = "khal -v ERROR";
        perf_record = "perf record --call-graph dwarf -e cycles --";
        gh = "PAGER= gh";

        eA = "vim ~/.config/aliasrc";
        eF = "vim ~/.config/functionrc";
        eB = "vim ~/.bashrc";
        eZ = "vim ~/.zshrc";
        eP = "vim ~/.profile";
        eG = "vim ~/.gitconfig";
        eI = "vim ~/.config/i3/config";
        eM = "vim ~/.config/mutt/muttrc";
        eN = "vim ~/.config/newsboat/config";
        eU = "vim ~/.config/newsboat/urls";
        eV = "vim -c 'cd ~/.config/nvim/'";

        ".." = "cd ..";
        h = "cd ~/";
        D = "cd ~/Downloads";
        sc = "cd ~/bin/scripts";
        cf = "cd ~/.config";
        mn = "cd /mnt";
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
    };
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [
          "Noto Color Emoji"
        ];
        monospace = [
          "FiraCode Nerd Font Mono"
        ];
      };
    };
  };

  system.stateVersion = "21.11";
}
