{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Kun for overlayen under; fjernes når den er tom
    nixpkgs-old.url = "github:NixOS/nixpkgs/55bfb4d7437bd4e09ab7cba58a43bd68eb310044";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Kanaler: stable (ingen ennå), preview, snapshot
    rex = {
      url = "https://pkgs.superlogical.com/rex/nix/preview.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-old, home-manager, rex, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./desktops/cosmic.nix
        ./desktops/plasma.nix
        ./desktops/niri.nix
        {
          # Midlertidige fikser; test uten dem etter `nix flake update`
          nixpkgs.overlays = [
            (final: prev: let old = nixpkgs-old.legacyPackages.x86_64-linux; in {
              # patchelf 0.18+ lager overlappende LOAD-segmenter, REAPER segfaulter i ld.so
              reaper = prev.reaper.overrideAttrs (o: {
                preFixup = (o.preFixup or "") + ''
                  export PATH=${old.patchelf}/bin:$PATH
                '';
              });
              # Skjermdeling stopper etter første frame; fiks fra cosmic-protocols#92.
              # https://github.com/pop-os/xdg-desktop-portal-cosmic/issues/389
              xdg-desktop-portal-cosmic = prev.xdg-desktop-portal-cosmic.overrideAttrs (o: {
                postPatch = (o.postPatch or "") + ''
                  for d in "$cargoDepsCopy"/*/cosmic-client-toolkit-*; do
                    patch -p1 -d "$d" < ${./patches/cosmic-screencopy-destroy-frame-first.patch}
                  done
                '';
              });
            })
          ];
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-bak";
          home-manager.users.benjamin.imports = [
            ./home.nix
            rex.homeManagerModules.default
          ];
        }
      ];
    };
  };
}
