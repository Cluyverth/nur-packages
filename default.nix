{ pkgs ? import <nixpkgs> {} }:

pkgs.lib.recurseIntoAttrs (
  pkgs.lib.makeExtensible (self:
    import ./pkgs {
      pkgs-base = pkgs;
      pkgs = self;
      lib = pkgs.lib;
    }
  )
)