# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d4bf0ec3-4905-498d-bbaa-16a9453ebf84";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3A09-1DA5";
      fsType = "vfat";
    };

  fileSystems."/mnt/internal" =
    { device = "/dev/disk/by-uuid/6de62098-e8bd-4e0d-8d4a-253c775dd616";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/003454e5-b1c4-43ac-aa8e-a07838ad9382"; }
    ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}