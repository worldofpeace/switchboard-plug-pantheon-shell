{ pkgs ? import /home/worldofpeace/Code/nix/nixpkgs {} }:

with pkgs;
with pantheon;
with gnome3;
with lib;

let

backgrounds-no-subdir = elementary-wallpapers;

# Move photo1,photo2,etc. to a elementary subdir
backgrounds-one-subdir = elementary-wallpapers.overrideAttrs(old: {
  postInstall = ''
    temp=$(mktemp -d)
    mv $out/share/backgrounds/* $temp
    mkdir $out/share/backgrounds/elementary
    mv $temp/* $out/share/backgrounds/elementary
  '';
});

backgrounds-two-subdirs = symlinkJoin {
  name = "wallpapers-2";
  # backgrounds/
  #   elementary/
  #   nixos/
  paths = [
    backgrounds-one-subdir
    nixos-artwork.wallpapers.simple-dark-gray
  ];
};

backgrounds-with-subdir-photos-in-parent = symlinkJoin {
  name = "wallpapers";
  # backgrounds/
  #   photo1,photo2
  #   nixos/
  paths = [
    backgrounds-no-subdir
    nixos-artwork.wallpapers.simple-dark-gray
  ];
};

backgrounds-with-subdirs-photos-in-parent = symlinkJoin {
  name = "wallpapers";
  # backgrounds/
  #   photo1,photo2
  #   nixos/
  #   elementary/
  paths = [
    backgrounds-one-subdir
    backgrounds-no-subdir
    nixos-artwork.wallpapers.simple-dark-gray
  ];
};

scenarios = {
  inherit
    backgrounds-no-subdir
    backgrounds-one-subdir
    backgrounds-two-subdirs
    backgrounds-with-subdir-photos-in-parent
    backgrounds-with-subdirs-photos-in-parent
  ;
};

pluginsToTest = mapAttrs (scenario: directory:
  callPackage ./plug.nix {
    inherit scenario;
    backgrounds-directory = directory;
  }
) scenarios;

in mapAttrs (scenario: plug:
  pantheon.switchboard-with-plugs.override {
    plugs = [ plug ];
    testName = scenario;
    useDefaultPlugs = false;
  }
) pluginsToTest
