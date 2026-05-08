{
  description = "qbittorrent-nox distroless image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = {
      qbittorrent-nox-image = pkgs.dockerTools.buildLayeredImage {
        name = "qbittorrent-nox";
        tag = "latest";
        contents = [ 
          pkgs.qbittorrent-nox
        ];
        fromImage = pkgs.dockerTools.pullImage {
          imageName = "gcr.io/distroless/static-debian12";
          imageDigest = "sha256:20bc6c0bc4d625a22a8fde3e55f6515709b32055ef8fb9cfbddaa06d1760f838";
          sha256 = "sha256-nTtTRnFVT//TiopktoapC/GncNlI5I6jhf7CsHpCpFY=";
        };
        extraCommands = ''
          mkdir -p /home/qbittorrent/.config
          ln -s ~/.config /config
        '';

        config = {
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
          ];
          Cmd = [ "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox" ];
          # Distroless non‑root user
          User = "qbittorrent";
          WorkingDir = "/config";
        };
      };
    };

    # Expose the qbittorrent-nox version for CI workflows
    qbittorrent-noxVersion = pkgs.qbittorrent-nox.version;

    defaultPackage.${system} = self.packages.${system}.qbittorrent-nox-image;
  };
}
