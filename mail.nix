{ config, lib, pkgs, ... }:
{
  systemd.user.services.mailsync = {
    startAt = "*:0/10";
    path = [ pkgs.pass ];
    script = ''
      export DISPLAY=:0
      export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
      export GPG_TTY=$TTY
      ${pkgs.libnotify}/bin/notify-send "Syncing Emails"
      ${pkgs.isync}/bin/mbsync -a
      wait
      ${pkgs.notmuch}/bin/notmuch new
    '';
  };

  environment.systemPackages = with pkgs; [
    neomutt
    mutt-wizard
    notmuch
    isync
    msmtp
    pass
    lynx
  ];
}
