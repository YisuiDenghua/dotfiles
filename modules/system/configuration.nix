{ config, pkgs, lib, inputs, ... }:

with lib;

let
  dbus-hyprland-environment = pkgs.writeTextFile {
    name = "dbus-hyprland-environment";
    destination = "/bin/dbus-hyprland-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gesettings/schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gesettings set $gnome_schema gtk-theme 'Adwaita'
    '';
  };

in {
  # disabledModules = [ "services/hardware/udev.nix" ];
  # imports = [ ./udev.nix ];
  environment = {
    variables = {
      NIXOS_CONFIG = "$HOME/.config/nixos/configuration.nix";
      NIXOS_CONFIG_DIR = "$HOME/.config/nixos/";
      NIXOS_OZONE_WL = "1";
      EDITOR = "nvim";
      TERMINAL = "st";
      BROWSER = "firefox";
      GBM_BACKEND = "nvidia-drm";
      __GL_GSYNC_ALLOWED = "0";
      __GL_VRR_ALLOWED = "0";
      DISABLE_QT5_COMPAT = "0";
      ANKI_WAYLAND = "1";
      DIRENV_LOG_FORMAT = "";
      WLR_DRM_NO_ATOMIC = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      MOZ_ENABLE_WAYLAND = "1";
      WLR_BACKEND = "vulkan";
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_SESSION_TYPE = "wayland";
      CLUTTER_BACKEND = "wayland";
      WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
    };
    loginShellInit = ''
      dbus-update-activation-environment --systemd DISPLAY
      eval $(ssh-agent)
      eval $(gnome-keyring-daemon --start)
      export GPG_TTY=$TTY
    '';
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 4d";
    };
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      auto-optimise-store = true;
      allowed-users = [ "yisui" ];
      substituters = [
        "https://cache.nixos.org"
        "https://fortuneteller2k.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "fortuneteller2k.cachix.org-1:kXXNkMV5yheEQwT0I4XYh1MaCSz+qg72k8XAi2PthJI="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  documentation.enable = false;
  services.journald.extraConfig = ''
    SystemMaxUse=50M
    RuntimeMaxUse=10M
  '';

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.dbus.packages = with pkgs; [ dconf ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme
    dbus-hyprland-environment
    configure-gtk
    cryptsetup

    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    flameshot
    ocs-url
    firefox-wayland
    vulkan-tools
    glxinfo
    nvidia-offload
    (google-chrome.override {
      commandLineArgs = [
        "--enable-features=WebUIDarkMode"
        "--force-dark-mode"
      ];
    })
    libsForQt5.ark
    hyfetch
    tdesktop
    libsForQt5.kate
    git
    github-cli
    networkmanagerapplet
    (vscode.override {
      commandLineArgs = [
        # "--enable-features=UseOzonePlatform"
        # "--ozone-platform=wayland"
        "--ozone-platform-hint=auto"
      ];
    })
    # (pkgs.callPackage ./hmcl-bin.nix {})
    steam-run
    virt-manager
    libsForQt5.breeze-gtk
    neofetch
    # krita
    mpv
    jdk8
    linphone
    openvpn
    papirus-folders
    gimp
    papirus-icon-theme
    libsForQt5.qtstyleplugin-kvantum
    # gnome.gnome-terminal
    # gnome.gnome-tweaks
    # gnomeExtensions.dash-to-dock
    # gnome.gedit
    # pavucontrol
    unrar
    virtualenv
    python310
    aria2
    kleopatra
    # gnomeExtensions.blur-my-shell
    # pop-icon-theme
    # marwaita-pop_os
    blackbox-terminal
    gnomeExtensions.tray-icons-reloaded
    # gnomeExtensions.dash-to-panel
    pfetch
    whitesur-icon-theme
    # whitesur-gtk-theme
    netease-cloud-music-gtk
    gparted
    obs-studio
    distrobox
    xorg.xhost


  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      open = true;
      powerManagement.enable = true;
      modesetting.enable = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        nvidia-vaapi-driver
      ];
    };
    pulseaudio.support32Bit = true;
  };

  environment.defaultPackages = [ ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  boot = {
    supportedFilesystems = [ "ntfs" ];
    cleanTmpDir = true;
    kernelParams = [
      "pti=on"
      "randomize_kstack_offset=on"
      "vsyscall=none"
      "slab_nomerge"
      "debugfs=off"
      "module.sig_enforce=1"
      "lockdown=confidentiality"
      "page_poison=1"
      "page_alloc.shuffle=1"
      "slub_debug=FZP"
      "sysrq_always_enabled=1"
      "processor.max_cstate=5"
      "idle=nomwait"
      "rootflags=noatime"
      "iommu=pt"
      "usbcore.autosuspend=-1"
      "sysrq_always_enabled=1"
      "lsm=landlock,lockdown,yama,apparmor,bpf"
      "loglevel=7"
      "rd.udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelPackages = pkgs.linuxPackages_latest;
    extraModprobeConfig = "options hid_apple fnmode=1 kvm_intel nested=1";
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";
      timeout = 1;
      grub = {
        enable = true;
        useOSProber = true;
        efiSupport = true;
        enableCryptodisk = true;
        device = "nodev";
        theme = null;
        backgroundColor = null;
        splashImage = null;
      };
    };
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-chinese-addons fcitx5-table-extra ];
  };



  networking = {
    # nameservers = [ "1.1.1.1" "1.0.0.1" ];
    networkmanager = {
      enable = true;
      unmanaged = [ "docker0" "rndis0" ];
      wifi.macAddress = "random";
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 443 80 25565 ];
      allowedUDPPorts = [ 443 80 44857 ];
      allowPing = false;
      logReversePathDrops = true;
    };

  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  programs = {
    ccache.enable = true;
    hyprland = {
      enable = true;
      package = pkgs.hyprland-nvidia;
    };
  };

  environment.etc."greetd/environments".text = ''
    Hyprland
  '';
  services = {
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "yisui";
      group = "wheel";
      dataDir = "/home/yisui/syncthing";
      configDir = "/home/yisui/.config/syncthing/";
      systemService = true;

    };
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "Hyprland";
          user = "yisui";
        };
        default_session = initial_session;
      };
    };

    gnome = {
      glib-networking.enable = true;
      gnome-keyring.enable = true;
    };
    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "lock";
      extraConfig = ''
        HandlePowerKey=suspend-then-hibernate
        HibernateDelaySec=3600
      '';
    };

    lorri.enable = true;
    udisks2.enable = true;
    printing.enable = true;
    fstrim.enable = true;

    # enable and secure ssh
    openssh = {
      enable = false;
      permitRootLogin = "no";
      passwordAuthentication = true;
    };

    # Use pipewire instead of soyaudio
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      wireplumber.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
  }; 

  systemd.services = {
    seatd = {
      enable = true;
      description = "Seat management daemon";
      script = "${pkgs.seatd}/bin/seatd -g wheel";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  users.users.yisui = {
    isNormalUser = true;
    # Enable ‘sudo’ for the user.
    extraGroups = [
      "wheel"
      "docker"
      "systemd-journal"
      "audio"
      "video"
      "input"
      "lp"
      "networkmanager"
    ];
    uid = 1000;
    # shell = pkgs.zsh;

  };

  fonts = {
    fonts = with pkgs; [
      material-icons
      material-design-icons
      roboto
      work-sans
      comic-neue
      source-sans
      twemoji-color-font
      comfortaa
      inter
      lato
      dejavu_fonts
      iosevka-bin
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      jetbrains-mono
      (nerdfonts.override { fonts = [ "Iosevka" "JetBrainsMono" ]; })
    ];

    enableDefaultFonts = false;

    fontconfig = {
      defaultFonts = {
        monospace = [
          "Iosevka Term"
          "Iosevka Term Nerd Font Complete Mono"
          "Iosevka Nerd Font"
          "Noto Color Emoji"
        ];
        sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
        serif = [ "Noto Serif" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  system.autoUpgrade.enable = false;

  # Security
  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"
    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "vivid"
    "gfs2"
    "ksmbd"
    "nfsv4"
    "nfsv3"
    "cifs"
    "nfs"
    "cramfs"
    "freevxfs"
    "jffs2"
    "hfs"
    "hfsplus"
    "squashfs"
    "udf"
    "bluetooth"
    "btusb"
    "uvcvideo" # webcam
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "omfs"
    "uvcvideo"
    "qnx4"
    "qnx6"
    "sysv"
  ];

  security = {
    protectKernelImage = true;
    lockKernelModules = false;
    rtkit.enable = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = [ pkgs.apparmor-profiles ];
    };
    pam.services = {
      login.enableGnomeKeyring = true;
      swaylock = {
        text = ''
          auth include login
        '';
      };
    };
    sudo.execWheelOnly = true;
  };

  boot.kernel.sysctl = {
    "kernel.yama.ptrace_scope" = 2;
    "kernel.kptr_restrict" = mkOverride 500 2;
    "net.core.bpf_jit_enable" = false;
    "kernel.ftrace_enabled" = false;
    "net.ipv4.conf.all.log_martians" = true;
    "net.ipv4.conf.all.rp_filter" = "1";
    "net.ipv4.conf.default.log_martians" = true;
    "net.ipv4.conf.default.rp_filter" = "1";
    "net.ipv4.icmp_echo_ignore_broadcasts" = true;
    "net.ipv4.conf.all.accept_redirects" = false;
    "net.ipv4.conf.all.secure_redirects" = false;
    "net.ipv4.conf.default.accept_redirects" = false;
    "net.ipv4.conf.default.secure_redirects" = false;
    "net.ipv6.conf.all.accept_redirects" = false;
    "net.ipv6.conf.default.accept_redirects" = false;
    "net.ipv4.conf.all.send_redirects" = false;
    "net.ipv4.conf.default.send_redirects" = false;
    "net.ipv6.conf.default.accept_ra" = 0;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_timestamps" = 0;
    "net.ipv4.tcp_rfc1337" = 1;
  };

  services.flatpak.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    # RISC-V
  boot.binfmt.emulatedSystems = [
    "riscv64-linux"
  ];

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "yisui" ];
  virtualisation.docker.enable = true;


  services.emacs = {
    enable = true;
    # defaultEditor = true;
  };

  system.stateVersion = "22.05"; # DONT TOUCH THIS
}
