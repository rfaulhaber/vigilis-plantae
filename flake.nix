{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.rust-overlay.overlays.default
          ];
          config = {};
        };
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            (rust-bin.stable.latest.default.override {
              extensions = ["rust-src"];
              targets = ["thumbv6m-none-eabi"];
            })
            rustfmt
            clippy
            rust-analyzer
            rustup

            cargo-binutils
            elf2uf2-rs
            openocd
            openocd-rp2040

            picocom
            udev
            pkg-config # this is needed by cargo-embed
          ];
        };
      };
      flake = {
      };
    };
}
