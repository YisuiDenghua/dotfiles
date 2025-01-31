{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.programs.tools;
  browser = [ "firefox.desktop" ];

  associations = {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;

    "audio/*" = [ "mpv.desktop" ];
    "video/*" = [ "mpv.dekstop" ];
    "image/*" = [ "imv.desktop" ];
    "application/json" = browser;
    "application/pdf" = [ "org.pwmt.zathura.desktop.desktop" ];
    "x-scheme-handler/tg" = [ "telegramdesktop.desktop" ];
    "x-scheme-handler/spotify" = [ "spotify.desktop" ];
    "x-scheme-handler/discord" = [ "WebCord.desktop" ];
  };
in {
  options.modules.programs.tools = { enable = mkEnableOption "programs"; };

  config = mkIf cfg.enable {
    xdg.configFile."bottom/bottom.toml".source = ./bottom.toml;
    services.gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
      enableZshIntegration = true;
    };
    programs = {
      bat = {
        enable = true;
        themes = {
          Catppuccin-frappe = builtins.readFile (pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "00bd462e8fab5f74490335dcf881ebe7784d23fa";
            sha256 = "yzn+1IXxQaKcCK7fBdjtVohns0kbN+gcqbWVE4Bx7G8=";
          } + "/Catppuccin-frappe.tmTheme");
        };
        config.theme = "Catppuccin-frappe";
      };
      bottom.enable = true;
      gpg.enable = true;
    };
    xdg = {
      userDirs = {
        enable = true;
        documents = "$HOME/other";
        download = "$HOME/download";
        videos = "$HOME/vids";
        music = "$HOME/music";
        pictures = "$HOME/pics";
        desktop = "$HOME/other";
        publicShare = "$HOME/other";
        templates = "$HOME/other";
      };
      mimeApps.enable = true;
      mimeApps.associations.added = associations;
      mimeApps.defaultApplications = associations;
    };

  };
}
