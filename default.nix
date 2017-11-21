with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "PIDGui";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    stdenv.cc
    meson
    vala
    pkgconfig
    gsl
    glib
    gnome3.gtk
    ninja
  ];
}
