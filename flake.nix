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

        extraCommands = ''
          #!${pkgs.runtimeShell}
          # Create user/group entries manually
          echo "root:x:0:0:root:/root:/bin/sh" > /etc/passwd
          echo "qbittorrent:x:1000:1000:qbittorrent User:/config:/bin/sh" >> /etc/passwd
          echo "root:x:0:" > /etc/group
          echo "qbittorrent:x:1000:" >> /etc/group
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
