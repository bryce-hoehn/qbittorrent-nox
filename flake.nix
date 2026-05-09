{
  description = "qbittorrent-nox distroless image using nix2container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = { self, nixpkgs, nix2container }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
    n2c = nix2container.outputs.packages.${system}.nix2container;

    distrolessImage = {
      imageName = "ghcr.io/podmania/base";
      imageDigest = "sha256:488c95da5023d19b22b342826d5ea1f3638ffe7642e58e9fc2fa8f4e4ff99289";
      sha256 = {
        x86_64-linux = "sha256-0pPkbjbKS+u9IJ3Gj76OxhHZN4NtPa4rJgFrZhptgVA=";
        aarch64-linux = "sha256-sto1YwQHJdVPAJMWfE8yyzsGy6JVFT4csr6zz3Ma12c=";
      };
    };
  in {
    packages.${system} = {
      qbittorrent-nox-image = n2c.buildImage {
        name = "qbittorrent-nox";
        tag = "latest";

        fromImage = n2c.pullImage {
          imageName = distrolessImage.imageName;
          imageDigest = distrolessImage.imageDigest;
          sha256 = distrolessImage.sha256.${system};
        };

        contents = [
          pkgs.qbittorrent-nox
        ];

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
        };
      };

      default = self.packages.${system}.qbittorrent-nox-image;
    };
    
    qbittorrent-noxVersion = pkgs.qbittorrent-nox.version;
  };
}
