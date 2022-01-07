{ pkgs, ... }:
{
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
  security.rtkit.enable = true;
  environment.systemPackages = with pkgs; [
    pulsemixer
    pavucontrol

    pulseaudio.out
  ];
}
