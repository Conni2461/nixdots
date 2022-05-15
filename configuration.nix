{ flake, config, pkgs, lib, ... }:
let
  isAtLeast24 = pkg: lib.versionAtLeast (lib.versions.majorMinor pkg.version) "2.4";
in
{
  imports =
    [
      ./1systems/hardware-configuration.nix
      ./1systems/uefi.nix
      ./1systems/nvidia.nix
      ./1systems/pipewire.nix
      ./1systems/bluetooth.nix
      ./2configs/dwm.nix
      ./2configs/gnome.nix
      ./2configs/virt.nix
      ./2configs/home.nix
      ./3modules/news.nix
      ./3modules/mail.nix
    ];

  nix = {
    buildCores = 0;
    useSandbox = true;
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 14d";
    };
    trustedUsers = [ "@wheel" "root" ];
    # For the hardened profile
    allowedUsers = [ "@users" ];
    # https://github.com/NixOS/nix/issues/719
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
      ${lib.optionalString (isAtLeast24 pkgs.nix || isAtLeast24 config.nix.package)
        "experimental-features = nix-command flakes"
      }
    '';
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        unstable = import <nixos-unstable> {
          config = config.nixpkgs.config;
        };
      };
    };
    overlays = lib.mkBefore (import ./4pkgs { inherit flake; });
  };

  boot = {
    cleanTmpDir = true;
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [
      config.boot.kernelPackages.rtl88x2bu
    ];
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.eno1.useDHCP = true;
  };

  time.timeZone = "Europe/Berlin";

  services = {
    xserver = {
      enable = true;
      xautolock = {
        enable = true;
        time = 10;
        locker = "${pkgs.slock}/bin/slock";
      };
    };
    gnome.gnome-keyring.enable = true;
    ratbagd.enable = true;
  };

  virtualisation.docker.enable = true;

  users.users.conni = {
    createHome = true;
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" "libvirtd" ];
  };

  environment.systemPackages = with pkgs; let
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
    fzf
    skim
    exa
    delta
    unstable.difftastic
    bat
    R
    tig
    imagemagickBig
    grc

    ctags
    unstable.vim
    neovim-nightly
    unstable.luajit
    unstable.luajitPackages.luacheck
    unstable.stylua
    sumneko-lua-language-server

    nodejs
    unstable.tree-sitter

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
    examiner

    sqlite
    sqlitebrowser

    nixpkgs-fmt
    rnix-lsp
    rust-analyzer
    nodePackages.bash-language-server
    nodePackages.prettier
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin
    nodePackages.vscode-json-languageserver
    nodePackages.typescript-language-server
    nodePackages.vim-language-server
    nodePackages.yaml-language-server
    shellcheck

    gnupg
    gopass
    bitwarden

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
    mangohud
    unstable.lutris

    xdg-utils
    sxiv

    flameshot
    feh
    xclip
    numlockx
    arandr

    nextcloud-client
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
    gamemode = {
      enable = true;
      settings.general.inhibit_screensaver = 0;
    };
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
