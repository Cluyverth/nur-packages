{ lib, stdenv, pkgs }:

let
  # Import necessary functions from nixpkgs
  inherit (pkgs) fetchurl appimageTools;
  
  pname = "helium";
  version = "0.6.7.1";
  
  # Definition map of assets by architecture (x86_64 and arm64)
  assetMap = {
    "x86_64-linux" = {
      assetName = "helium-${version}-x86_64.AppImage";
      hash = "sha256-fZTBNhaDk5EeYcxZDJ83tweMZqtEhd7ws8AFUcHjFLs=";
    };
    "aarch64-linux" = {
      assetName = "helium-${version}-arm64.AppImage";
      hash = "sha256-daIKkKrDR+HZq4dbGL8E92eHVE277TvdqxbvTAWZDvM=";
    };
  };
  
  # Selects the asset information based on the current system architecture
  selectedAsset = 
    if lib.hasAttr stdenv.system assetMap then
      lib.getAttr stdenv.system assetMap
    else
      # Throws an error if the architecture is not supported
      builtins.throw "The architecture ${stdenv.system} is not supported by Helium Browser (AppImage).";

  inherit (selectedAsset) assetName;

  # Download the AppImage source
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/${assetName}";
    hash = selectedAsset.hash; 
  };

  # Extract the AppImage contents to access icons and .desktop files
  contents = appimageTools.extractType2 { inherit pname version src; };

in
# Wrap the AppImage to make it executable on NixOS
appimageTools.wrapType2 {
  inherit pname version src;

  nameForWrapper = pname;

  # Post-installation commands to set up desktop integration
  extraInstallCommands = ''
    # Create necessary directories
    mkdir -p "$out/share/applications"
    mkdir -p "$out/share/lib/helium"
    
    # Copy localization files and shared resources
    cp -r ${contents}/opt/helium/locales "$out/share/lib/helium"
    cp -r ${contents}/usr/share/* "$out/share"
    
    # Try to copy the .desktop file from root, fallback to usr/share if not found
    cp "${contents}/${pname}.desktop" "$out/share/applications/" || \
    cp "${contents}/usr/share/applications/${pname}.desktop" "$out/share/applications/"
    
    # Fix the 'Exec' line in the .desktop file to point to the wrapper
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
  '';

  # Runtime dependencies required by the browser (common for Electron/CEF apps)
  extraPkgs = pkgs: with pkgs; [
    libglvnd
    alsa-lib
    libva
    libdrm
    gtk3
    nss
    nspr
    mesa
    libnotify 
    xorg.libXrandr
  ];

  # Package metadata
  meta = with lib; {
    description = "Helium Browser, Internet without interruptions";
    homepage = "https://github.com/imputnet/helium-linux";
    license = licenses.gpl3; 
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "helium";
  };
}