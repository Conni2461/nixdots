{ lib, ... }:
{
  boot.loader = {
    grub = {
      enable = true;
      splashImage = null;
      device = "nodev";
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
