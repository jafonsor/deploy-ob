{ dockerTag ? "latest" }:

let
  pkgs = import ./default.nix {};

  nixpkgs = pkgs.reflex.nixpkgs;

  # add config and static folders to the server derivation
  serverExe-config = nixpkgs.runCommand "serverExe-config"
                                {}
                                ''
                                  mkdir $out
                                  cp -r ${pkgs.exe}/* $out
                                  cp -r ${./config} $out/config
                                  cp -r ${./static} $out/static
                                '';



  docker-image = nixpkgs.dockerTools.buildImage {
    name = "deploy-ob";
    tag = "${dockerTag}";
    config = {
      WorkingDir = "${serverExe-config}/";
      Cmd = [ "./backend" ];
    };
  };

in { inherit docker-image; }