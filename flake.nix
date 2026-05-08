{
  description = "qbittorrent-nox distroless image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};

    distrolessImage = {
      imageName = "gcr.io/distroless/static-debian12";
      imageDigest = "sha256:20bc6c0bc4d625a22a8fde3e55f6515709b32055ef8fb9cfbddaa06d1760f838";
      sha256 = {
        x86_64-linux = "sha256-nTtTRnFVT//TiopktoapC/GncNlI5I6jhf7CsHpCpFY=";
        aarch64-linux = "sha256-RMKwrKl6lMjNO5G4W5B1I9y10ToOMOS++G4E9/gvfSQ=";
      };
    };
  in {
    packages.${system} = {
      qbittorrent-nox-image = pkgs.dockerTools.buildLayeredImage {
        name = "qbittorrent-nox";
        tag = "latest";
        fromImage = pkgs.dockerTools.pullImage {
          inherit (distrolessImage) imageName imageDigest;
          sha256 = distrolessImage.sha256.${system};
        };
        contents = [
          pkgs.qbittorrent-nox
        ];
        fakeRootCommands = ''
          mkdir -p ./config ./data
          chown -R 1000:1000 /config /data
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
            "QBT_PROFILE=/config"
          ];
          Cmd = [ "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox" ];
          User = "1000";
          WorkingDir = "/config";
        };
      };
    };
    
    qbittorrent-noxVersion = pkgs.qbittorrent-nox.version;

    defaultPackage.${system} = self.packages.${system}.qbittorrent-nox-image;
  };
}
