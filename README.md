# PIDGUI

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A small "simulator" of a PID-Controller. This programs function is to visualize
the workings of a PID-Controller. To help understand it.

For information on the usage use the `--help` option.

## Build

To build use the included build script:

```
./build.sh
```

### Preprocessor Options

Some options are configurable at compile time:

  * `NOCENTER` disables the possibility to center the view on a right click
  * `NOCSVEXPORT` disables the csv export
  * `NOPNGEXPORT` disables the png export
  * `NORESET` disables the reset button
  * `NOSVGEXPORT` disables the svg export
  * `NOTICS` disables the tics on the axies
  * `NOZOOM` disables the possibility to zoom the view

Use this to pass the compile flags:

```
VALAFLAGS="-D NORESET" ./build.sh
```
