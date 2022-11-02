{
  description = "My NixOS configuration";
  # https://github.com/sioodmy/dotfiles

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    hyprland.url = "github:hyprwm/Hyprland/";
    nixos-cn.url = "github:nixos-cn/flakes";
    nixos-cn.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    waybar = {
      url = "github:Alexays/Waybar";
      flake = false;
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, nixos-cn, nur,  ... }:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      lib = nixpkgs.lib;

      mkSystem = pkgs: system: hostname:
        pkgs.lib.nixosSystem {
          system = system;
          modules = [
            ({ ... }: {
              environment.systemPackages = [
                nixos-cn.legacyPackages.${system}.netease-cloud-music
                nixos-cn.legacyPackages.${system}.wechat-uos
              ];
              nix.binaryCaches = [
                "https://nixos-cn.cachix.org"
              ];
              nix.binaryCachePublicKeys = [
	          "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg="
	          ];

              imports = [
                nixos-cn.nixosModules.nixos-cn-registries
                nixos-cn.nixosModules.nixos-cn
              ];
            })

            ({ config, ... }: {
              environment.systemPackages = [
	        # config.nur.repos.xddxdd.qqmusic
                config.nur.repos.xddxdd.fcitx5-breeze
	            config.nur.repos.linyinfeng.wemeet
                config.nur.repos.linyinfeng.clash-for-windows
              ];
            })

            { networking.hostName = legion-y9000x; }
            (./. + "/hosts/${hostname}/system.nix")
            (./. + "/hosts/${hostname}/hardware-configuration.nix")
            ./modules/system/configuration.nix
            inputs.hyprland.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                users.sioodmy = (./. + "/hosts/${hostname}/user.nix");
              };
              nixpkgs.overlays = [
                (final: prev: {
                  catppuccin-folders =
                    final.callPackage ./overlays/catppuccin-folders.nix { };
                  catppuccin-cursors =
                    prev.callPackage ./overlays/catppuccin-cursors.nix { };
                  catppuccin-gtk =
                    prev.callPackage ./overlays/catppuccin-gtk.nix { };
                  waybar = prev.waybar.overrideAttrs (oldAttrs: {
                    src = inputs.waybar;
                    mesonFlags = oldAttrs.mesonFlags
                      ++ [ "-Dexperimental=true" ];
                    patchPhase = ''
                      substituteInPlace src/modules/wlr/workspace_manager.cpp --replace "zext_workspace_handle_v1_activate(workspace_handle_);" "const std::string command = \"hyprctl dispatch workspace \" + name_; system(command.c_str());"
                    '';
                  });
                  hyprland-nvidia =
                    inputs.hyprland.packages.${system}.default.override {
                      nvidiaPatches = true;
                      wlroots =
                        inputs.hyprland.packages.${system}.wlroots-hyprland.overrideAttrs
                        (old: {
                          patches = (old.patches or [ ])
                            ++ [ ./overlays/screenshare-patch.diff ];
                        });

                    };
                })
                inputs.nixpkgs-wayland.overlay
              ];
            }

          ];
          specialArgs = { inherit inputs; };
        };
    in {
      nixosConfigurations = {
        graphene = mkSystem inputs.nixpkgs "x86_64-linux" "nixos";
        thinkpad = mkSystem inputs.nixpkgs "x86_64-linux" "legion-y9000x";
      };

      devShell.${system} = pkgs.mkShell {
        packages = [ pkgs.nixpkgs-fmt ];
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    };
}
