{
  description = "qbittorrent-nox distroless image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};

    distrolessImage = {
      imageName = "ghcr.io/podmania/base";
      imageDigest = "sha256:bf251a2cdaebb929ad7803671a3e5d48a0d9d4bcff43c2199d268e04ca8401bc";
      sha256 = {
        x86_64-linux = "sha256-q1ez8v8w0ZTscHsl9TJLYfP+Zq6VXwtbarNP0HC7S4c=";
        aarch64-linux = "sha256-cNH7zwR3+39WxI5pp9nFeJiO4wKMcGz0cjkl0bnGKgM=";
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
