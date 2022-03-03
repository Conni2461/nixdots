{ config, lib, pkgs, ... }:
{
  systemd.user.services.newsup = {
    startAt = "*:0/10";
    script = ''
      export DISPLAY=:0
      ${pkgs.iputils}/bin/ping -q -t 1 -c 1 $(${pkgs.iproute2}/bin/ip r | grep -m 1 default | cut -d ' ' -f 3) > /dev/null || exit
      ${pkgs.procps}/bin/pgrep -x newsboat > /dev/null && exit

      echo 🔃 > ~/.config/newsboat/.update
      ${pkgs.libnotify}/bin/notify-send "Updating RSS feeds..."
      ${pkgs.newsboat}/bin/newsboat -x reload
      rm -f ~/.config/newsboat/.update

      feeds=$(${pkgs.sqlite}/bin/sqlite3 ~/.local/share/newsboat/cache.db "SELECT rss_feed.title FROM rss_feed;")
      IFS='
      '
      for feed in $feeds; do
        ${pkgs.sqlite}/bin/sqlite3 ~/.local/share/newsboat/cache.db \
            "DELETE FROM rss_item WHERE id IN (
               SELECT id FROM rss_item
               WHERE feedurl = \"$feed\"
               ORDER BY rss_item.pubDate
               DESC LIMIT -1 OFFSET 100
             );
            "
      done
      ${pkgs.libnotify}/bin/notify-send "RSS feed update complete."
    '';
  };

  environment.systemPackages = with pkgs; [
    newsboat
  ];
}
