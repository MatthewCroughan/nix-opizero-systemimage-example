{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./configuration.nix
    "${modulesPath}/installer/cd-dvd/sd-image-armv7l-multiplatform.nix"
  ];

  nixpkgs.crossSystem = {
    system = "armv7l-linux";
  };

  nixpkgs.overlays = [(self: super: {
  # Does not cross-compile...
  alsa-firmware = pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";

  # A "regression" in nixpkgs, where python3 pycryptodome does not cross-compile.
  crda = pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";

  # Regression caused by including a new package in the closure
  # Added in f1922cdbdc608b1f1f85a1d80310b54e89d0e9f3
  smartmontools = super.smartmontools.overrideAttrs(old: {
    configureFlags = [];
  });

  # Git uses perl somehow, this does not cross-compile at this time.
  git = super.git.override { perlSupport = false; };

  # spidermonkey, needed for polkit, needed for wpa_supplicant,
  # does not cross-compile.
  wpa_supplicant = self.pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";
  })];

  zramSwap = {
    memoryPercent = 90;
    enable = true;
    algorithm = "zstd";
  };

  # Slim it down a bit by disabling documentation.
  documentation.enable = false;

  # I want that 5.12 goodness!
  boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;

  # I want a podman container running the official PiHole image
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole:v5.8.1-stretch";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "80:80"
    ];
    environment = {
      TZ = "Europe/London";
      VIRTUAL_HOST = "pi.hole";
      PROXY_LOCATION = "pi.hole";
      ServerIP = "127.0.0.1";
      WEBPASSWORD = "piratesrus";
    };
  };
}
