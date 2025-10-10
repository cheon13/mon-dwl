{
  description = "DWL - dwm pour Wayland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      dwl = pkgs.stdenv.mkDerivation rec {
        pname = "dwl";
        version = "0.6";

        src = pkgs.fetchFromGitHub {
          owner = "djpohly";
          repo = "dwl";
          rev = "v${version}";
          sha256 = "sha256-UR0lOnE/nGmOUm61f4fu0Ed65PCsXzr0cb9TzE1Jxuw=";
        };

        nativeBuildInputs = with pkgs; [
          pkg-config
          wayland-scanner
        ];

        buildInputs = with pkgs; [
          wayland
          wayland-protocols
          wlroots_0_17
          libxkbcommon
          pixman
          libinput
        ];
        
        # Variables d'environnement pour pkg-config
        PKG_CONFIG_PATH = "${pkgs.wlroots_0_17}/lib/pkgconfig";
        
        # Désactiver git pour la version
        makeFlags = [
          "PREFIX=$(out)"
          "MANDIR=$(out)/share/man"
        ];

        # Optionnel : copier config.h personnalisé
        # prePatch = ''
        #   cp ${./config.h} config.h
        # '';

        meta = with pkgs.lib; {
          description = "dwm pour Wayland";
          homepage = "https://github.com/djpohly/dwl";
          license = licenses.gpl3Only;
          platforms = platforms.linux;
          mainProgram = "dwl";
        };
      };
    in
    {
      packages.${system} = {
        default = dwl;
        dwl = dwl;
      };

      apps.${system}.default = {
        type = "app";
        program = "${dwl}/bin/dwl";
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = dwl.buildInputs ++ dwl.nativeBuildInputs;
        shellHook = ''
          echo "Environnement de développement DWL"
          echo "Compiler avec: make"
        '';
      };
    };
}
