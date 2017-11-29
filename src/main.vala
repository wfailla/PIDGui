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

#if NOSVGEXPORT
    var Button = (Widget) App.builder.get_object("SVGExport_Button");
    Button.hide();
#endif

#if NOPNGEXPORT
    var Button = (Widget) App.builder.get_object("PNGExport_Button");
    Button.hide();
#endif

#if NOCSVEXPORT
    var Button = (Widget) App.builder.get_object("CSVExport_Button");
    Button.hide();
#endif

#if NORESET
      var Button = (Widget) App.builder.get_object("Reset_Button");
      Button.destroy();
#endif

    App.main_window.show_all();
    Gtk.main();
    return 0;

  }
}
