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
      Env = [ "PORT=8000" ];
      WorkingDir = "${serverExe-config}/";
      Cmd = [ "${nixpkgs.bash}/bin/bash" "-c" "./backend -p $PORT" ];
    };
  };

in { inherit docker-image; }