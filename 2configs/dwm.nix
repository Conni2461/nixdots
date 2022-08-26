{ pkgs, fetchFromGitHub, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "dwm";
          rev = "493eeb1fd976ee82134a20cecde0da10d92251c2";
          hash = "sha256-3NLZNGkfh5SrtdZYEFROLJDitLGGSI5Cy5JLggO5ato=";
        };
      });
      dmenu = super.dmenu.overrideAttrs (_: {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "dmenu";
          rev = "a1a35a8a0352008d1148f4dcb4ec4ff488ce1842";
          hash = "sha256-+4R/hguk5aD7HZfUgc/v67NiHUPJ+Clep2UrwwrfaPg=";
        };
      });
      st = super.st.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "st";
          rev = "51edfa5e7db51b11ee4ad0f471b4b7c7572e6a38";
          hash = "sha256-YY6gkTV4jxRKnjOaebVUs0rqqRvyIA+H7Z+jT6o72t4=";
        };
        buildInputs = with pkgs; oldAttrs.buildInputs ++ [ harfbuzz ];
      });
      slock = super.slock.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "slock";
          rev = "bded8aa5889386c68ad9ab0b40f0ca7d905c3046";
          hash = "sha256-IxHdxgsbVhC6JAHivThFpHawfM8PMwyyWFqheHZ0QHk=";
        };
        buildInputs = with pkgs; oldAttrs.buildInputs ++ [
          xorg.libXinerama
          imlib2
        ];
      });
    })
  ];

  systemd.services.display-manager.restartIfChanged = false;
  services.xserver = {
    enable = true;
    layout = "de";
    xkbModel = "pc105";
    xkbVariant = "nodeadkeys";
    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "none+dwm";
    displayManager.startx.enable = true;
    windowManager.dwm.enable = true;
    xkbOptions = "caps:escape";
  };

  environment.systemPackages = with pkgs; let
    rdq = writeShellScriptBin "rdq" ''
      #!/bin/sh
      prompt="$1"
      shift
      com="$1"
      shift

      [ $(printf "No\nYes" | dmenu -i -p "$prompt" "$@") = "Yes" ] && $com
    '';
  in
  [
    rdq
    dmenu
    st
    clipmenu
  ];
  environment.extraInit = ''
    xset r rate 300 50
  '';

  programs = {
    slock.enable = true;
  };
}
