# Processus pour mettre à jour l'installation nixos pour une nouvelle version de DWL

1. On développe dans ~/Projets/mon-dwl/
2. On test avec nix build ou nix develop
3. On push les modifications sur Github de mon-dwl
4. Sur la machine destination, dans le répertoire ~/.dotfiles/, on met à jour le flake avec ``` nix flake update mon-dwl```
5. ```sudo nixos-rebuild switch --flake ~/.dotfiles``` ou ```./build "message commit"```
