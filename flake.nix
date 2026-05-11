{
  description = "qbittorrent-nox distroless image using nix2container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix2container.url = "github:nlewo/nix2container";
    base.url = "github:podmania/base";
  };

  outputs = { self, nixpkgs, nix2container, base }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
    n2c = nix2container.outputs.packages.${system}.nix2container;
    version = "5.2.0";
    srcHash = "sha256-Ha2Pc08gztI9fupQMykVz5wVIyUu9dRtChxjAGSxcOQ=";
    pkg = pkgs.qbittorrent-nox.overrideAttrs (old: {
      inherit version;
      src = pkgs.fetchFromGitHub {
        owner = "qbittorrent";
        repo = "qBittorrent";
        rev = "release-${version}";
        hash = srcHash;
      };
    });
    imageConfig = {
      ExposedPorts = {
        "8080/tcp" = {};
        "6881/tcp" = {};
        "6881/udp" = {};
      };
      Volumes = {
        "/config" = {};
        "/data" = {};
      };
      Env = [
        "QBT_WEBUI_PORT=8080"
        "QBT_PROFILE=/config"
      ];
      Cmd = [ "${pkg}/bin/qbittorrent-nox" ];
    };
  in {
    packages.${system} = {
      qbittorrent-nox-image = n2c.buildImage {
        name = "qbittorrent-nox";
        tag = "latest";
        fromImage = base.packages.${system}.base-image;
        config = imageConfig;
      };

      qbittorrent-nox-debug-image = n2c.buildImage {
        name = "qbittorrent-nox";
        tag = "latest-debug";
        fromImage = base.packages.${system}.base-debug-image;
        config = imageConfig;
      };

      qbittorrent-nox = pkg;

      default = self.packages.${system}.qbittorrent-nox-image;
    };

    qbittorrent-noxVersion = version;
  };
}
