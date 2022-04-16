{ config, pkgs, lib, theme, ... }:
with lib;
let
  cfg = config.modules.desktop.lockscreen;
  sleep-noti = pkgs.writeScript "sleep-noti" ''
    #! ${pkgs.bash}/bin/bash
    ${pkgs.libnotify}/bin/notify-send 'Sleeping in 60 seconds..'
  '';
  lockscreen = (with theme.colors;
    pkgs.writeScriptBin "lockscreen" ''
      #! ${pkgs.zsh}/bin/zsh
      background=#${bg}
      insidecolor=#${bg}ff
      insidevercolor=#${bg}ff
      insidewrongcolor=#${c1}ff
      ringcolor=#${ac}1A
      ringvercolor=#${c4}ff
      ringwrongcolor=#${c1}ff
      keyhlcolor=#${c2}ff
      bshlcolor=#${c1}ff
      layoutcolor=#${ac}ff
      seperatorcolor=#${ba}00
      timecolor=#${fg}7f
      datecolor=#${fg}ff
      verifcolor=#${fg}ff
      wrongcolor=#${bg}ff
      ${pkgs.i3lock-color}/bin/i3lock-color \
        -n \
        --indicator \
        -c $background \
        -S=0 \
        --inside-color=$insidecolor \
        --insidever-color=$insidevercolor \
        --insidewrong-color=$insidewrongcolor \
        \
        --ring-color=$ringcolor \
        --ringver-color=$ringvercolor \
        --ringwrong-color=$ringwrongcolor \
        \
        --line-uses-inside \
        --keyhl-color=$keyhlcolor \
        --bshl-color=$bshlcolor \
        \
        --layout-color=$layoutcolor \
        --separator-color=$seperatorcolor \
        --radius=160 \
        --ring-width=24 \
        --noinput-text="Enter Password" \
        \
        --clock \
        \
        --time-color=$timecolor \
        --time-str="%H:%M:%S" \
        --time-pos="x+w/2:y+h/1.8" \
        --time-font="monospace" \
        --time-size=22 \
        \
        --date-color=$datecolor \
        --date-str="%A" \
        --date-pos="x+w/2:y+h/1.95" \
        --date-font="monospace" \
        --date-size=57 \
        \
        --verif-text="" \
        --verif-color=$verifcolor \
        --verif-font="monospace" \
        --verif-pos="x+w/2:y+h/2" \
        --verif-size=30 \
        \
        --wrong-text="" \
        --wrong-color=$wrongcolor \
        --wrong-font="monospace" \
        --wrong-pos="x+w/2:y+h/2" \
        --wrong-size=30 &&\
    '');
in {

  options.modules.desktop.lockscreen = {
    enable = mkEnableOption "lockscreen";
    autolock = mkOption {
      type = types.bool;
      default = true;
      description = "Enable XAutolock";
    };
    time = mkOption {
      type = types.ints.unsigned;
      default = 10;
      description = "Autolock timer";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.i3lock-color lockscreen ];

    services.screen-locker = {
      enable = true;
      inactiveInterval = config.modules.desktop.lockscreen.time;
      xautolock.enable = config.modules.desktop.lockscreen.autolock;
      xautolock.extraOptions = [
        "-corners '--00'"
        "-cornersize 20"
        "-notify 60"
        "-notifier ${sleep-noti}"
      ];
      lockCmd = "${lockscreen}/bin/lockscreen";
    };

    services.sxhkd.keybindings = mkIf config.modules.services.sxhkd.enable {
      "super + shift + p" = "${lockscreen}/bin/lockscreen";
    };

  };

}
