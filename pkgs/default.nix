{ pkgs, pkgs-base, lib }:

lib.mapAttrs (name: value: 
  pkgs-base.callPackage (./. + "/${lib.removePrefix "./" value}") { }
) (builtins.fromJSON (builtins.readFile ./pkgs.json))