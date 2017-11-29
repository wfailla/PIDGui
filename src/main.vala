using Gtk;

class Main : GLib.Object {
  private static bool version = false;

  private const GLib.OptionEntry[] options = {
    { "version", 0,0, OptionArg.NONE, ref version, "Display version", null},
    { null }
  };

  public static int main (string[] args) {
    try {
       var opt_context = new OptionContext ("- OptionContext example");
       opt_context.set_help_enabled (true);
       opt_context.add_main_entries (options, null);
       opt_context.parse (ref args);
    } catch (OptionError e) {
      stdout.printf ("error: %s\n", e.message);
      stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
      return 0;
    }

    if (version) {
      stdout.printf ("Test 0.1\n");
      return 0;
    }

    Gtk.init (ref args);
    gui.handler App = new gui.handler();

    //if (no_svg_export && no_png_export && no_csv_export) {
    //  stdout.printf ("Error");
    //  return 1;
    //}

#if NOSVGEXPORT && NOPNGEXPORT && NOCSVEXPORT
    var Export_Button = (Widget) App.builder.get_object("Export_Button");
    Export_Button.destroy();
#endif

#if NOSVGEXPORT
    var SVG_Button = (Widget) App.builder.get_object("SVGExport_Button");
    SVG_Button.hide();
#endif

#if NOPNGEXPORT
    var PNG_Button = (Widget) App.builder.get_object("PNGExport_Button");
    PNG_Button.hide();
#endif

#if NOCSVEXPORT
    var CSV_Button = (Widget) App.builder.get_object("CSVExport_Button");
    CSV_Button.hide();
#endif

#if NORESET
    var RESET_Button = (Widget) App.builder.get_object("Reset_Button");
    RESET_Button.destroy();
#endif

    App.main_window.show_all();
    Gtk.main();
    return 0;

  }
}
