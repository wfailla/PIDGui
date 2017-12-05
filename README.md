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

### Interfaces

Some of the implementation is interchangeable:

SaveDialogHandler:

  * `public void SaveDialogHandler (List<double?> Points, Gsl.Vector Position, int x_size, int y_size)`
  * `public void saveResponse (Dialog source, int response)`

Renderer:

  * `public virtual void triangle (Context ctx, double x, double y, int rotation)`
  * `public virtual void Background (Context ctx, double width, double height)`
  * `public virtual void Axies (Context ctx, double posiX, double posiY, double width, double hight)`
  * `public virtual void Graph (Context ctx, List<double?> Points, double offsetX, double offsetY)`
  * `public virtual int getTriangleSize ()`
  * `public virtual int getTicHight ()`
  * `public virtual int getTicWidth ()`
  * `public virtual void setTriangleSize (int value)`
  * `public virtual void setTicHight (int value)`
  * `public virtual void increaseTicWidth (int value)`

PIDController:

  * `public virtual void reset()`
  * `public virtual void PIDcalc(double Input, double Setpoint)`
  * `public virtual void setKp (double value)`
  * `public virtual void setKi (double value)`
  * `public virtual void setKd (double value)`
  * `public virtual void setTimeInMs (double value)`
  * `public virtual int getTimeInMs ()`
  * `public virtual double getResult ()`
  * `public virtual double getOldResult ()`
