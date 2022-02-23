{ config, lib, pkgs, ... }:
{
  systemd.user.services.newsup = {
    startAt = "*:0/10";
    script = ''
      export DISPLAY=:0
      ${pkgs.iputils}/bin/ping -q -t 1 -c 1 $(${pkgs.iproute2}/bin/ip r | grep -m 1 default | cut -d ' ' -f 3) > /dev/null || exit
      ${pkgs.procps}/bin/pgrep -x newsboat > /dev/null && exit
      ${pkgs.libnotify}/bin/notify-send "Updating RSS feeds..."
      ${pkgs.newsboat}/bin/newsboat -x reload
      ${pkgs.libnotify}/bin/notify-send "RSS feed update complete."
    '';
  };

  environment.systemPackages = with pkgs; [
    newsboat
  ];
}
