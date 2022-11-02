{ pkgs, lib, ... }: {

  boot.kernelParams = [
    "button.lid_init_state=open"
    "i915.enable_psr=0"
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/efi";
    grub = {
      enable = true;
      device = "nodev";
      theme = pkgs.nixos-grub2-theme;
      #theme = pkgs.libsForQt5.breeze-grub;
      # default = "1";
      efiSupport = true;
      extraEntries = ''
        menuentry "Windows" {
          search --file --no-floppy --set=root /EFI/Microsoft/Boot/bootmgfw.efi
          chainloader (''${root})/EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };

  hardware.video.hidpi.enable = true;

  services.tlp.enable = false;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_BOOST_ON_AC = "1";
    CPU_BOOST_ON_BAT = "0";
    SCHED_POWERSAVE_ON_AC = "0";
    SCHED_POWERSAVE_ON_BAT = "1";
  };
}
