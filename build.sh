# valac -g -o main --pkg gsl --pkg posix --pkg gio-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 *.vala

if [ -d build ]; then
  rm -rf build
fi

mkdir -p build
cd build

meson ..
ninja

cp ../src/PIDGui.glade .
