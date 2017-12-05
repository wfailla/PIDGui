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
    
    // var SVG_Button = (Widget) App.builder.get_object("SVGExport_Button");
    // SVG_Button.hide();
    
    // var PNG_Button = (Widget) App.builder.get_object("PNGExport_Button");
    // PNG_Button.hide();

    App.main_window.show_all();
    Gtk.main();
    return 0;

  }
}
