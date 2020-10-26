{ pkgs ? import /home/worldofpeace/Code/nix/nixpkgs { }
, backgrounds-directory ? pkgs.elementary-wallpapers
, scenario # have a useful .drv name
}:

with pkgs;
with pantheon;
with gnome3;

stdenv.mkDerivation rec {
  pname = "${scenario}-switchboard-plug-pantheon-shell";
  version = "dev";

  src = lib.cleanSource ./.;

  passthru = {
    updateScript = nix-update-script {
      attrPath = "pantheon.${pname}";
    };
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkgconfig
    vala
  ];

  buildInputs = [
    bamf
    elementary-dock
    elementary-settings-daemon
    gala
    gexiv2
    glib
    gnome-desktop
    granite
    gtk3
    libgee
    pantheon-settings-daemon
    switchboard
    wingpanel
  ];

  postPatch = ''
    substituteInPlace src/Views/Wallpaper.vala \
      --subst-var-by DIR "${backgrounds-directory}/share/backgrounds" # change me for tests
  '';

  meta = with stdenv.lib; {
    description = "Switchboard Desktop Plug";
    homepage = "https://github.com/elementary/switchboard-plug-pantheon-shell";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = pantheon.maintainers;
  };
}
