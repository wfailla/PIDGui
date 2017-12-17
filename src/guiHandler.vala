using Gtk;
using Posix;
using Cairo;
using Gsl;

namespace gui {

  public interface SaveDialogHandler : Object {    
    public void SaveDialogHandler (List<double?> Points, Gsl.Vector Position, int x_size, int y_size){
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public void saveResponse (Dialog source, int response){
      Posix.stdout.printf ("Not Implemented!\n");
    }
  }
  
  public interface Renderer : Object {
    public virtual void triangle (Context ctx, double x, double y, int rotation) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public virtual void Background (Context ctx, double width, double height) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public virtual void Axies (Context ctx, double posiX, double posiY, double width,
      double hight ) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public virtual void Graph (Context ctx, List<double?> Points, double offsetX,
      double offsetY) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    
    public virtual int getTriangleSize () {
      Posix.stdout.printf ("Not Implemented!\n");
      return 0;
    }
    public virtual int getTicHight () {
      Posix.stdout.printf ("Not Implemented!\n");
      return 0;
    }
    public virtual int getTicWidth () {
      Posix.stdout.printf ("Not Implemented!\n");
      return 0;
    }
    
    public virtual void setTriangleSize (int value) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public virtual void setTicHight (int value) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public virtual void increaseTicWidth (int value) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
  }

  public interface PIDController : Object {
    public virtual void reset() {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public virtual void PIDcalc(double Input, double Setpoint) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    
    public virtual void setKp (double value) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public virtual void setKi (double value) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public virtual void setKd (double value) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    public virtual void setTimeInMs (double value) {
      Posix.stdout.printf ("Not Implemented!\n");
    }
    
    public virtual int getTimeInMs () {
      Posix.stdout.printf ("Not Implemented!\n");
      return 0;
    }
    public virtual double getResult () {
      Posix.stdout.printf ("Not Implemented!\n");
      return 0;
    }
    public virtual double getOldResult () {
      Posix.stdout.printf ("Not Implemented!\n");
      return 0;
    }
  }

  public class handler : Object {

    public Window main_window;
    public Builder builder = new Builder();

    public PID pid = new PID();

    public string Result = "";
    public string OldResult = "";
    public List<double?> Points = new List<double?> ();
    public Gsl.Vector position = new Gsl.Vector (2);
    public Gsl.Vector deltaCenter = new Gsl.Vector (2);

    public bool dragging = false;
    public bool initialDraw = true;

    public TextView CalcResult_TextView = null;
    public Entry KP_Entry = null;
    public Entry KI_Entry = null;
    public Entry KD_Entry = null;
    public Entry SP_Entry = null;
    public Entry Input_Entry = null;
    public SpinButton SpinButton = null;
    public PopoverMenu Export_Menu = null;
    public DrawingArea Diagram = null;
    public Button CalcButton = null;

    public string CSV = null;
    public List<double?> Inputs = null;
    
    Renderer renderer = new drawer.simpleDraw();

    construct {
      builder.add_objects_from_file("PIDGui.glade", {"window", "CalcResult_TextBuffer", "Export_Menu"});

      this.CalcResult_TextView = (TextView) builder.get_object("CaclResult_TextView");
      this.KP_Entry = (Entry) builder.get_object("KP_Entry");
      this.KI_Entry = (Entry) builder.get_object("KI_Entry");
      this.KD_Entry = (Entry) builder.get_object("KD_Entry");
      this.SP_Entry = (Entry) builder.get_object("SP_Entry");
      this.Input_Entry = (Entry) builder.get_object("Input_Entry");
      this.CalcButton = (Button) builder.get_object("CSVImport");

      this.Export_Menu = (PopoverMenu) builder.get_object("Export_Menu");

      this.Diagram = (DrawingArea) builder.get_object("Diagram");
      this.Diagram.add_events(Gdk.EventMask.BUTTON_PRESS_MASK
                                | Gdk.EventMask.BUTTON_RELEASE_MASK
                                | Gdk.EventMask.POINTER_MOTION_MASK
                                | Gdk.EventMask.SCROLL_MASK);

      this.CSV = "Time; KP; KI; KD; Input; Setpoint; Result; OldResult;\n";

      this.SpinButton = (SpinButton) builder.get_object("Calc_Number");
      this.SpinButton.set_range(1,50);
      this.SpinButton.set_increments(1,1);

      builder.connect_signals(this);

      this.main_window = builder.get_object("window") as Window;

    }

    [CCode (instance_pos = -1)]
    public void on_Entry_Changed(Entry source) {
      try {
        var regex = new Regex ("([^\\d\\.])");
        string text = source.get_text();
        string newText = regex.replace (text, -1, 0, "");

        source.set_text(newText);
      } catch (RegexError e) {
        warning ("%s", e.message);
      }
    }

    [CCode (instance_pos = -1)]
    public void on_Calc_Button_clicked(Button source) {

      int iterations = this.SpinButton.get_value_as_int();
      
      if (Inputs == null) {
        CalcButton.set_sensitive(false);
        
        for (int i = 0; i<iterations; i++) {
          this.pid.kp = double.parse(this.KP_Entry.get_text());
          this.pid.ki = double.parse(this.KI_Entry.get_text());
          this.pid.kd = double.parse(this.KD_Entry.get_text());

          string Time = this.pid.TimeInMs.to_string();
          this.pid.PIDcalc(double.parse(this.Input_Entry.get_text()),
            double.parse(this.SP_Entry.get_text()));
          this.OldResult = pid.OldResult.to_string();
          this.Result = pid.Result.to_string();
          this.Points.append(pid.Result);

          this.CalcResult_TextView.buffer.text += @"$Time\t\t$Result\t\t$OldResult\n";

          TextIter iter;
          this.CalcResult_TextView.buffer.get_end_iter(out iter);

          this.CalcResult_TextView.scroll_to_mark(
            this.CalcResult_TextView.buffer.create_mark (null, iter, true), 0.4,
            false, 0.5, 0.5);

          this.CSV += @"$Time; ";
          this.CSV += this.KP_Entry.get_text() + "; ";
          this.CSV += this.KI_Entry.get_text() + "; ";
          this.CSV += this.KD_Entry.get_text() + "; ";
          this.CSV += this.Input_Entry.get_text() + "; ";
          this.CSV += this.SP_Entry.get_text() + "; ";
          this.CSV += @"$Result; $OldResult;\n";

          this.pid.TimeInMs += 1;

          this.Diagram.queue_draw ();
        }
      } else {
        CalcButton.set_sensitive(true);
        for (int i = 0; i<iterations; i++) {
          this.pid.kp = double.parse(this.KP_Entry.get_text());
          this.pid.ki = double.parse(this.KI_Entry.get_text());
          this.pid.kd = double.parse(this.KD_Entry.get_text());

          if (this.Inputs.length() > this.pid.TimeInMs) {

            string Time = this.pid.TimeInMs.to_string();
            this.pid.PIDcalc(this.Inputs.nth(this.pid.TimeInMs).data,
              double.parse(this.SP_Entry.get_text()));
            this.OldResult = pid.OldResult.to_string();
            this.Result = pid.Result.to_string();
            this.Points.append(pid.Result);

            this.CalcResult_TextView.buffer.text += @"$Time\t\t$Result\t\t$OldResult\n";

            TextIter iter;
            this.CalcResult_TextView.buffer.get_end_iter(out iter);

            this.CalcResult_TextView.scroll_to_mark(
              this.CalcResult_TextView.buffer.create_mark (null, iter, true), 0.4,
              false, 0.5, 0.5);

            this.CSV += @"$Time; ";
            this.CSV += this.KP_Entry.get_text() + "; ";
            this.CSV += this.KI_Entry.get_text() + "; ";
            this.CSV += this.KD_Entry.get_text() + "; ";
            this.CSV += this.Input_Entry.get_text() + "; ";
            this.CSV += this.SP_Entry.get_text() + "; ";
            this.CSV += @"$Result; $OldResult;\n";

            this.pid.TimeInMs += 1;
            this.Diagram.queue_draw ();
          } else {
            this.CalcResult_TextView.buffer.text += "No more data!\n";
          }
        }
      }
    }

    [CCode (instance_pos = -1)]
    public void on_Reset_Button_clicked(Button source) {
      this.pid.reset();
      this.CalcResult_TextView.buffer.text = "Time\tResult\tOldResult\n";
      this.CSV = "";
      this.Points = new List<double?> ();
      this.position.set(0, Diagram.get_allocated_width() / 2);
      this.position.set(1, Diagram.get_allocated_height() / 2);
      this.pid.TimeInMs = 0;

      this.Diagram.queue_draw ();
    }

    [CCode (instance_pos = -1)]
    public void on_Export_Button_clicked(Button source) {
      this.Export_Menu.popup();
    }

    [CCode (instance_pos = -1)]
    public void on_Delete_Window() {
      Gtk.main_quit();
    }

    [CCode (instance_pos = -1)]
    public bool draw(DrawingArea source, Context ctx) {
      if(this.initialDraw) {
        this.position.set(0, source.get_allocated_width() / 2);
        this.position.set(1, source.get_allocated_height() / 2);
        this.initialDraw = false;
      }

      var style_context = source.get_style_context();
      
      // set bg color
      var bgColor = style_context.get_background_color(source.get_state_flags());
      ctx.set_source_rgba ( bgColor.red, bgColor.green, bgColor.blue, bgColor.alpha );

      renderer.Background (ctx, source.get_allocated_width(),
        source.get_allocated_height());

      // set fg color
      var fgColor = style_context.get_color(source.get_state_flags());
      ctx.set_source_rgb ( fgColor.red, fgColor.green, fgColor.blue );

      renderer.Axies (ctx, this.position.get(0), this.position.get(1),
        source.get_allocated_width(), source.get_allocated_height());

      renderer.Graph (ctx, this.Points, this.position.get(0),
        this.position.get(1));

      return false;
    }
    
    [CCode (instance_pos = -1)]
    public bool on_Diagram_Scrolled(DrawingArea source, Gdk.EventScroll event) {
      if (event.direction == Gdk.ScrollDirection.UP) {
        if (renderer.getTicWidth() > 5) {
          renderer.increaseTicWidth(-5);
          this.Diagram.queue_draw ();
        }
      } else if (event.direction == Gdk.ScrollDirection.DOWN) {
        if (renderer.getTicWidth() < 120) {
          renderer.increaseTicWidth(5);
          this.Diagram.queue_draw ();
        }
      }
      return true;
    }

    [CCode (instance_pos = -1)]
    public bool on_Diagram_Motion(DrawingArea source, Gdk.EventButton event) {

      if(this.dragging) {
        Gsl.Vector tmpVec = new Gsl.Vector(2);
        tmpVec.set(0,event.x);
        tmpVec.set(1,event.y);

        tmpVec.sub(this.position);
        this.position.add(this.deltaCenter);
        this.position.add(tmpVec);
        this.Diagram.queue_draw ();
      }
      return true;
    }

    [CCode (instance_pos = -1)]
    public bool on_Diagram_Pressed(DrawingArea source, Gdk.EventButton event) {

      if (event.button == 1) {
        if(!this.dragging) {
          this.dragging = true;

          Gsl.Vector tmpVec = new Gsl.Vector(2);
          tmpVec.set(0,event.x);
          tmpVec.set(1,event.y);

          tmpVec.sub(this.position);
          this.deltaCenter.sub(tmpVec);
        }
      }
      if (event.button == 3) {
        this.position.set(0, Diagram.get_allocated_width() / 2);
        this.position.set(1, Diagram.get_allocated_height() / 2);
        this.Diagram.queue_draw ();
      }
      return true;
    }

    [CCode (instance_pos = -1)]
    public bool on_Diagram_Released(DrawingArea source, Gdk.EventButton event) {

      if(this.dragging) {
        this.dragging = false;
        this.deltaCenter.set(0, 0);
        this.deltaCenter.set(1, 0);

        this.Diagram.queue_draw ();
      }
      return true;
    }
    
    [CCode (instance_pos = -1)]
    public void on_CSVImport_Button_clicked(Button source) {
      var builder = new Builder();
      var File_Dialog_Handler = new dialog.CSVOpenDialogHandler ();

      try {
        builder.add_objects_from_file("PIDGui.glade", {"File_Dialog"});
      } catch (GLib.Error e) {
        Posix.stderr.printf ("Could not load save file dialog: %s\n", e.message);
        exit(1);
      }
      //builder.connect_signals(File_Dialog_Handler);

      var File_Dialog = (FileChooserDialog) builder.get_object("File_Dialog");

      File_Dialog.set_transient_for ((Window) this.CalcResult_TextView.get_toplevel());
      File_Dialog.add_buttons (
        "_Cancel", Gtk.ResponseType.CANCEL,
        "_Open", Gtk.ResponseType.OK);
        
      File_Dialog.set_action(Gtk.FileChooserAction.OPEN);

      // nur fix eigentlich sollte man buidler.connect_signals benutzen
      File_Dialog.response.connect(File_Dialog_Handler.openResponse);

      File_Dialog.run();

      File_Dialog.destroy();
      
      File_Dialog_Handler.CSV.foreach ((entry) => {
		    Posix.stdout.puts (entry.to_string());
		    Posix.stdout.putc ('\n');
	    });
	    
	    this.Inputs = File_Dialog_Handler.CSV.copy();
	    
      this.Input_Entry.set_sensitive (false);
    }

    [CCode (instance_pos = -1)]
    public void on_CSVExport_Button_clicked(Button source) {
      var builder = new Builder();
      var File_Dialog_Handler = new dialog.CSVSaveDialogHandler (this.CSV);

      try {
        builder.add_objects_from_file("PIDGui.glade", {"File_Dialog"});
      } catch (GLib.Error e) {
        Posix.stderr.printf ("Could not load save file dialog: %s\n", e.message);
        exit(1);
      }
      //builder.connect_signals(File_Dialog_Handler);

      var File_Dialog = (FileChooserDialog) builder.get_object("File_Dialog");

      File_Dialog.set_transient_for ((Window) this.CalcResult_TextView.get_toplevel());
      File_Dialog.add_buttons (
        "_Cancel", Gtk.ResponseType.CANCEL,
        "_Save", Gtk.ResponseType.OK);

      // nur fix eigentlich sollte man buidler.connect_signals benutzen
      File_Dialog.response.connect(File_Dialog_Handler.saveResponse);

      File_Dialog.run();

      File_Dialog.destroy();
    }

    [CCode (instance_pos = -1)]
    public void on_Choose_Export_Button_clicked(Button source) {
      var builder = new Builder();
      try {
        builder.add_objects_from_file("PIDGui.glade", {"File_Dialog"});
      } catch (GLib.Error e) {
        Posix.stderr.printf ("Could not load save file dialog: %s\n", e.message);
        exit(1);
      }
      //builder.connect_signals(File_Dialog_Handler);
      

      var File_Dialog = (FileChooserDialog) builder.get_object("File_Dialog");
      File_Dialog.set_transient_for ((Window) this.CalcResult_TextView.get_toplevel());
      File_Dialog.add_buttons (
        "_Cancel", Gtk.ResponseType.CANCEL,
        "_Save", Gtk.ResponseType.OK);

      SaveDialogHandler File_Dialog_Handler = null;

      switch (source.get_name()) {
      case "PNGExport_Button":
        File_Dialog_Handler = new dialog.PNGSaveDialogHandler();
        (File_Dialog_Handler as dialog.PNGSaveDialogHandler).SaveDialogHandler (this.Points,
          this.position,
          this.Diagram.get_allocated_width(),
          this.Diagram.get_allocated_height());

        // nur fix eigentlich sollte man buidler.connect_signals benutzen
        File_Dialog.response.connect((File_Dialog_Handler as dialog.PNGSaveDialogHandler).saveResponse);
        break;
      case "SVGExport_Button":
        File_Dialog_Handler = new dialog.SVGSaveDialogHandler();
        (File_Dialog_Handler as dialog.SVGSaveDialogHandler).SaveDialogHandler (this.Points,
          this.position,
          this.Diagram.get_allocated_width(),
          this.Diagram.get_allocated_height());

        // nur fix eigentlich sollte man buidler.connect_signals benutzen
        File_Dialog.response.connect((File_Dialog_Handler as dialog.SVGSaveDialogHandler).saveResponse);
        break;
      default:
        Posix.stdout.printf("Error!\n");
        break;
      }

      File_Dialog.run();

      File_Dialog.destroy();
    }
  }
}
