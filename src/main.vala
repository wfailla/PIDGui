using Gtk;

class Main : GLib.Object {
  private static bool version = false;
  private static bool no_svg_export = false;
  private static bool no_png_export = false;
  private static bool no_csv_export = false;
  private static bool no_reset = false;

  private const GLib.OptionEntry[] options = {
    { "version", 0,0, OptionArg.NONE, ref version, "Display version", null},
    { "no_svg_export", 0,0, OptionArg.NONE, ref no_svg_export, "No svg export", null},
    { "no_png_export", 0,0, OptionArg.NONE, ref no_png_export, "No png export", null},
    { "no_csv_export", 0,0, OptionArg.NONE, ref no_csv_export, "No csv export", null},
    { "no_reset", 0,0, OptionArg.NONE, ref no_reset, "No reset button", null},
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

    if (no_svg_export && no_png_export && no_csv_export) {
      stdout.printf ("Error");
      return 1;
    }

    if (no_svg_export) {
      var Button = (Widget) App.builder.get_object("SVGExport_Button");
      Button.hide();
    }

    if (no_png_export) {
      var Button = (Widget) App.builder.get_object("PNGExport_Button");
      Button.hide();
    }

    if (no_csv_export) {
      var Button = (Widget) App.builder.get_object("CSVExport_Button");
      Button.hide();
    }

#if NORESET
      var Button = (Widget) App.builder.get_object("Reset_Button");
      Button.destroy();
#endif

    App.main_window.show_all();
    Gtk.main();
    return 0;

  }
}
