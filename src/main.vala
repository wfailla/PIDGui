using Gtk;

int main (string[] args) {
  Gtk.init(ref args);

  try {
    var builder = new Builder();
    builder.add_objects_from_file("PIDGui.glade", {"window",
      "CalcResult_TextBuffer", "Export_Menu"});

    // create handler object
    var handler = new gui.handler ();

    handler.CalcResult_TextView = (TextView) builder.get_object("CaclResult_TextView");
    handler.KP_Entry = (Entry) builder.get_object("KP_Entry");
    handler.KI_Entry = (Entry) builder.get_object("KI_Entry");
    handler.KD_Entry = (Entry) builder.get_object("KD_Entry");
    handler.SP_Entry = (Entry) builder.get_object("SP_Entry");
    handler.Input_Entry = (Entry) builder.get_object("Input_Entry");

    handler.Export_Menu = (PopoverMenu) builder.get_object("Export_Menu");
    
    handler.Diagram = (DrawingArea) builder.get_object("Diagram");
    handler.Diagram.add_events(Gdk.EventMask.BUTTON_PRESS_MASK
                              | Gdk.EventMask.BUTTON_RELEASE_MASK
                              | Gdk.EventMask.POINTER_MOTION_MASK);

    handler.CSV = "Time; KP; KI; KD; Input; Setpoint; Result; OldResult;\n";
    
    handler.SpinButton = (SpinButton) builder.get_object("Calc_Number");
    handler.SpinButton.set_range(1,50);
    handler.SpinButton.set_increments(1,1);

    builder.connect_signals(handler);

    var window = builder.get_object("window") as Window;
    window.show_all();
    Gtk.main();
  } catch(Error e) {
    stderr.printf ("Could not load UI: %s\n", e.message);
    return 1;
  }

  return 0;
}
