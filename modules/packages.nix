{ inputs, pkgs, config, ... }:
let
  mpv-unwrapped = pkgs.mpv-unwrapped.overrideAttrs (o: {
    src = pkgs.fetchFromGitHub {
      owner = "mpv-player";
      repo = "mpv";
      rev = "48ad2278c7a1fc2a9f5520371188911ef044b32c";
      sha256 = "sha256-6qbv34ysNQbI/zff6rAnVW4z6yfm2t/XL/PF7D/tjv4=";
    };
  });
in {
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    wf-recorder
    todo
    mpv-unwrapped
    rofi-wayland
    pavucontrol
    imv
    hyperfine
    slurp
    grim
    transmission-gtk
    fzf
    gum
    unzip
    libnotify
    gnupg
    ripgrep
    rsync
    imagemagick
    unrar
    tealdeer
    killall
    du-dust
    bandwhich
    grex
    fd
    xfce.thunar
    xh
    jq
    figlet
    lm_sensors
    keepassxc
    dconf
    gcc
    rustc
    rustfmt
    cargo
  ];
}
