{ ... }:
{
  imports = [ <home-manager/nixos> ];

  home-manager.users.conni = { pkgs, ... }: {
    home.packages = [ pkgs.atool ];
    programs.bash.enable = true;

    programs.git = {
      enable = true;
      userName = "Simon Hauser";
      userEmail = "Simon-Hauser@outlook.de";

      delta = {
        enable = true;
        options = {
          line-numbers = true;
          side-by-side = true;

          file-modified-label = "modified:";
        };
      };
      lfs.enable = true;

      aliases = {
        aa = "add --all";
        ap = "add --patch";
        bv = "branch -vv";
        ba = "branch -ra";
        bd = "branch -d";
        ca = "commit --amend -v -S";
        cb = "checkout -b";
        st = "status --short --branch";
        ci = "commit -v -S";
        co = "checkout";
        di = "diff";
        mm = "merge --no-ff -S";
        br = "branch";
        unstage = "reset HEAD --";
        last = "log -1 HEAD --show-signature";
        uncommit = "reset --soft HEAD~1";
        pl = "pull --autostash";
        sp = "submodule foreach git pull origin master";
        rb = "rebase -S";

        wip = "!git ci -m \"[WIP]: $(date)\"";
        fpr = "!f() { git fetch origin pull/$1/head:pr-$1; git checkout pr-$1; }; f";

        ls = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
        ll = "log --pretty=format:'%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate --numstat";

        # External commands
        af = "!fgst af";
        ah = "!fgst ah";
        cf = "!fgst cf";
        ch = "!fgst ch";
        uf = "!fgst uf";

        fcb = "!fcob";
        fct = "!fcot";
        fcc = "!fcoc";
      };

      extraConfig = {
        core = { editor = "nvim"; };
        color = {
          ui = true;
          diff = "auto";
          status = "auto";
          branch = "auto";
        };
        pull = { rebase = true; };
        diff = { tool = "vimdiff3"; };
      };

      ignores = [ "tags" ".ctagsignore" ];
    };

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 34560000;
      maxCacheTtl = 34560000;
    };

    xsession.numlock.enable = true;

    home.stateVersion = "22.05";
  };
}
