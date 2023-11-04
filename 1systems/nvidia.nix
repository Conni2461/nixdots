{ pkgs, ... }:
{
  hardware = {
    nvidia.powerManagement.enable = true;
    opengl = {
      enable = true;
      setLdLibraryPath = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      serverLayoutSection = ''
        Option         "Xinerama" "0"
      '';
      screenSection = ''
        Option         "nvidiaXineramaInfoOrder" "DFP-3"
        Option         "metamodes" "DP-2: 2560x1440_240 +2560+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0: 2560x1440_75 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
        Option         "SLI" "Off"
        Option         "MultiGPU" "Off"
        Option         "BaseMosaic" "off"
        Option         "RandRRotation" "on"
      '';
    };
  };
}
