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
  in {
    packages.${system} = {
      qbittorrent-nox-image = n2c.buildImage {
        name = "qbittorrent-nox";
        tag = "latest";
        fromImage = base.packages.${system}.base-image;
        copyToRoot = [ pkgs.qbittorrent-nox ];
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
          WorkingDir = "/config";
        };
      };

      default = self.packages.${system}.qbittorrent-nox-image;
    };

    qbittorrent-noxVersion = pkgs.qbittorrent-nox.version;
  };
}
