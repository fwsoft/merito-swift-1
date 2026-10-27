{
  description = "SwiftLabs dev environment — official Swift 6.3 toolchain, no Docker, no manual installs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # nixpkgs' own `swift` is built from source and ships without
      # libIndexStore.so, which SwiftPM needs to discover test cases on
      # Linux, so `swift test` fails. Use the official swift.org toolchain
      # instead — a stock Ubuntu build that expects an FHS layout, so it
      # runs inside buildFHSEnv rather than being patched to fit nixpkgs.
      swiftVersion = "6.3";
      ubuntuVersion = "24.04";
      ubuntuTag = pkgs.lib.replaceStrings [ "." ] [ "" ] ubuntuVersion;

      swiftToolchain = pkgs.stdenvNoCC.mkDerivation {
        pname = "swift-toolchain";
        version = swiftVersion;

        src = pkgs.fetchurl {
          url = "https://download.swift.org/swift-${swiftVersion}-release/ubuntu${ubuntuTag}/swift-${swiftVersion}-RELEASE/swift-${swiftVersion}-RELEASE-ubuntu${ubuntuVersion}.tar.gz";
          hash = "sha256-hbp90WlgtgriprgXMbriNvt85TOaB2Qo/JhNlgZo/b0=";
        };

        dontFixup = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r usr/* $out/
          runHook postInstall
        '';
      };

      swiftFhs = pkgs.buildFHSEnv {
        name = "swift-fhs";

        targetPkgs =
          p: with p; [
            swiftToolchain
            binutils
            curl
            gcc
            gcc-unwrapped
            gcc-unwrapped.lib
            glibc
            glibc.dev
            libedit
            libuuid
            libxml2_13
            ncurses
            python3
            sqlite
            zlib
          ];

        profile = ''
          export PATH=${swiftToolchain}/bin:$PATH
          # ldconfig indexes only libncursesw.so.6, but the toolchain links against
          # the libncurses.so.6 compatibility symlink, so point the loader at the
          # FHS library directory directly.
          export LD_LIBRARY_PATH=/usr/lib64:/usr/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
        '';

        runScript = pkgs.writeShellScript "swift-exec" ''
          exec "$@"
        '';
      };

      swiftCommands = [
        "swift"
        "swiftc"
        "swift-build"
        "swift-test"
        "swift-run"
        "swift-package"
        "swift-format"
        "sourcekit-lsp"
      ];

      swiftBin = pkgs.runCommand "swift-bin-${swiftVersion}" { } ''
        mkdir -p $out/bin
        for name in ${pkgs.lib.concatStringsSep " " swiftCommands}; do
          printf '#!${pkgs.runtimeShell}\nexec ${swiftFhs}/bin/swift-fhs %s "$@"\n' "$name" > $out/bin/$name
          chmod +x $out/bin/$name
        done
      '';
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
          swiftBin
          pkgs.gh
          pkgs.shellcheck
        ];
      };
    };
}
