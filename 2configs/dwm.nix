{ pkgs, fetchFromGitHub, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "conni2461";
          repo = "dwm";
          rev = "26ee48f07290bb72fa61543c40df47472f574fe8";
          sha256 = "sha256:0ck20134q7gk0xflabhzcfnkz35avr51r8rn8ajrabj1bb4px428";
        };
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
          rev = "b4ee37c2af469b5f03beae3ddce674c9ca0933de";
          sha256 = "sha256:01z7qgni59c7pqcjd9gdz0bcrrdgiby4fzn4w9x48caqg4b9f94w";
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
