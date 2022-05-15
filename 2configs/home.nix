{ ... }:
{
  imports = [ <home-manager/nixos> ];

  home-manager.users.conni = { pkgs, ... }: {
    home.packages = [ pkgs.atool ];
    programs.bash.enable = true;

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 34560000;
      maxCacheTtl = 34560000;
    };
  };
}
