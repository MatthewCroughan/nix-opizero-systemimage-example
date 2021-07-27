{
  inputs = {
    crosspkgs = {
       url = "github:matthewcroughan/nixpkgs/armv7lfixes/podman";
    };
  };

  outputs = inputs:
    let
      mkSystem = pkgs: system: hostname:
        pkgs.lib.nixosSystem {
          system = system;
          modules = [(./. + "/hosts/${hostname}/armv7l-linux.nix")];
          specialArgs = { inherit inputs; };
        };
    in rec {

    nixosConfigurations = {
      opizero  = mkSystem inputs.crosspkgs "x86_64-linux" "opizero";
    };

    images = {
      opizero = inputs.self.nixosConfigurations.opizero.config.system.build.sdImage;
    };
  };
}

