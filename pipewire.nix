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
    media-session.config.bluez-monitor.rules = [
      {
        matches = [{ "device.name" = "~bluez_card.*"; }];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            "bluez5.autoswitch-profile" = true;
          };
        };
      }
      {
        matches = [
          { "node.name" = "~bluez_input.*"; }
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "update-props" = {
            "node.pause-on-idle" = false;
          };
        };
      }
    ];
  };
  security.rtkit.enable = true;
  environment.systemPackages = with pkgs; [
    pulsemixer
    pavucontrol

    pulseaudio.out
  ];
}
