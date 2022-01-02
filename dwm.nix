{ pkgs, fetchFromGitHub, ... }:
{
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
  ];

  systemd.services.display-manager.restartIfChanged = false;
  services = {
    xserver = {
      enable = true;
      layout = "de";
      xkbModel = "pc105";
      xkbVariant = "nodeadkeys";
      displayManager.lightdm.enable = true;
      displayManager.defaultSession = "none+dwm";
      displayManager.startx.enable = false;
      windowManager.dwm.enable = true;
      xkbOptions = "caps:escape";
    };
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

  programs = {
    slock.enable = true;
  };
}
