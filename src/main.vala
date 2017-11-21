using Gtk;

class Main : GLib.Object {

  public static int main (string[] args) {

    Gtk.init (ref args);
    gui.handler App = new gui.handler();
    App.main_window.show_all();
    Gtk.main();
    return 0;

  }
}
