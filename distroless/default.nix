{pkgs ? import (builtins.fetchTarball {
    name = "nixos-unstable-2021-06-25";
    url = "https://github.com/nixos/nixpkgs/archive/e85975942742a3728226ac22a3415f2355bfc897.tar.gz";
    sha256 = "0zg5c9if4dlk4f0w14439ixjv50m04yfxf0l3bmrhhsgq1f6yk0m";
}){ system = "x86_64-linux"; }}:
let
    debs = with pkgs; stdenv.mkDerivation {
        name = "debs";
        
        nativeBuildInputs = [ dpkg ];

        src = let
            expr = with pkgs.vmTools; with pkgs.vmTools.debDistros; debClosureGenerator {
                name = debian10x86_64.name;
                packagesLists = [debian10x86_64.packagesList];
                urlPrefix = debian10x86_64.urlPrefix;
                packages = ["libc6"];
            };
        in import expr {
            inherit (pkgs) fetchurl;
        };

        buildCommand = "
            mkdir unpacked
            for i in $src
            do
                echo $i
                dpkg-deb --extract $i ./unpacked
            done
            cp -r ./unpacked $out
        ";
    };
    
    
in with pkgs; dockerTools.buildLayeredImage {
    name = "distroless-test";
    contents = [ debs ];
    config = {
        User = "65532:65532";
        Env = [
            "HOME=/home/nonroot"
            "USER=nonroot"
        ];
    };
    fakeRootCommands = ''
        mkdir -p ./home/nonroot
        chown 65532 ./home/nonroot
        mkdir -p ./tmp
        chmod 01777 ./tmp
    '';
}