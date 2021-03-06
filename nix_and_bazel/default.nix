{pkgs ? import (builtins.fetchTarball {
    name = "nixos-unstable-2021-06-25";
    url = "https://github.com/nixos/nixpkgs/archive/e85975942742a3728226ac22a3415f2355bfc897.tar.gz";
    sha256 = "0zg5c9if4dlk4f0w14439ixjv50m04yfxf0l3bmrhhsgq1f6yk0m";
}){ system = "x86_64-linux"; }}:

pkgs.dockerTools.buildLayeredImage {
  name = "hello-world-build";
  contents = [
      pkgs.bazel_4
      pkgs.gcc
  ];
  config = {
    WorkingDir = "/src";
    User = "1000:1000";
    Env = [
        "HOME=/home/nobody"
        "USER=nobody"
    ];
    Cmd = [ "/bin/bazel" 
            "build"
            "//main:hello-world" ];
  };
  fakeRootCommands = ''
    mkdir -p ./home/nobody
    chown 1000 ./home/nobody
    mkdir -p ./tmp
    chmod 1777 ./tmp
  '';
}

