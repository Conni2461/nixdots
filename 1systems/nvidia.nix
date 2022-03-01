{ pkgs, ... }:
{
  hardware = {
    nvidia.powerManagement.enable = true;
    opengl = {
      enable = true;
      setLdLibraryPath = true;
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
        Option         "nvidiaXineramaInfoOrder" "DFP-1"
        Option         "metamodes" "HDMI-0: 1920x1080 +0+360 {ForceCompositionPipeline=On}, DP-0: 2560x1440 +1920+0 {ForceCompositionPipeline=On}"
        Option         "AllowIndirectGLXProtocol" "off"
      '';
    };
  };
}
