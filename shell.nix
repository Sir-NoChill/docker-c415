{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShellNoCC {
  buildInputs = [
    pkgs.docker-compose
  ];
}

