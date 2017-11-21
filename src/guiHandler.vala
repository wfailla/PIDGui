using Gtk;
using Posix;
using Cairo;

namespace gui {
  public class handler : Object {

    public PID pid = new PID();

    private string Result = "";
    private string OldResult = "";
    private List<double?> Points = new List<double?> ();
    private Gsl.Vector position = new Gsl.Vector (2);
    private Gsl.Vector deltaCenter = new Gsl.Vector (2);
    
    private bool dragging = false;
    private bool initialDraw = true;

    public TextView CalcResult_TextView = null;
    public Entry KP_Entry = null;
    public Entry KI_Entry = null;
    public Entry KD_Entry = null;
    public Entry SP_Entry = null;
    public Entry Input_Entry = null;
    public SpinButton SpinButton = null;
    public PopoverMenu Export_Menu = null;
    public DrawingArea Diagram = null;

    public string CSV = null;

    [CCode (instance_pos = -1)]
    public void on_Entry_Changed(Entry source) {
      try {
        var regex = new Regex ("([^\\d\\.])");
        string text = source.get_text();
        string newText = regex.replace (text, -1, 0, "");
        
        /*
        var numberOfPoints = new Regex ("([\\.])");
        
        if (numberOfPoints.match(text).get_capture_count() > 1) {
          Posix.stdout.printf("two dots detected\n");
          text = newText;
          newText = numberOfPoints.replace (text, -1, 0, "");
        }*/
        
        source.set_text(newText);
      } catch (RegexError e) {
        warning ("%s", e.message);
      }
    }

    [CCode (instance_pos = -1)]
    public void on_Calc_Button_clicked(Button source) {
    
      int iterations = this.SpinButton.get_value_as_int();
    
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
    }

    [CCode (instance_pos = -1)]
    public void on_Reset_Button_clicked(Button source) {
      this.pid.reset();
      this.CalcResult_TextView.buffer.text = "Time\tResult\tOldResult\n";
      this.CSV = "";
      this.Points = new List<double?> ();
      this.position.set(0, Diagram.get_allocated_width() / 2);
      this.position.set(1, Diagram.get_allocated_height() / 2);
      
      this.Diagram.queue_draw ();
    }

    [CCode (instance_pos = -1)]
    public void on_Export_Button_clicked(Button source) {
      this.Export_Menu.popup();
      //this.Export_Popover.popup();
      //source.set_active(!source.get_active());
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

      Background (ctx, source.get_allocated_width(), source.get_allocated_height());
      
      // set fg color
      var fgColor = style_context.get_color(source.get_state_flags());
      ctx.set_source_rgb ( fgColor.red, fgColor.green, fgColor.blue );
      Axies (ctx, this.position.get(0), this.position.get(1),
            source.get_allocated_width(), source.get_allocated_height());
      
      Graph (ctx, this.Points, this.position.get(0), this.position.get(1));

      return false;
    }

    [CCode (instance_pos = -1)]    
    public bool on_Diagram_Motion(DrawingArea source, Gdk.EventButton event) {
    
      if(this.dragging) {
        Posix.stdout.printf("Motion\n");
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
          Posix.stdout.printf("pressed\n");
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
        Posix.stdout.printf("Released\n");
        this.deltaCenter.set(0, 0);
        this.deltaCenter.set(1, 0);
        
        this.Diagram.queue_draw ();
      }
      return true;
    }

    [CCode (instance_pos = -1)]
    public void on_CSVExport_Button_clicked(Button source) {

      var builder = new Builder();
      var Save_File_Dialog_Handler = new dialog.SaveDialogHandler (this.CSV);
      
      try {
        builder.add_objects_from_file("PIDGui.glade", {"Save_File_Dialog"});
      } catch (Error e) {
        Posix.stderr.printf ("Could not load save file dialog: %s\n", e.message);
        exit(1);
      }
      //builder.connect_signals(Save_File_Dialog_Handler);
      
      var Save_File_Dialog = (FileChooserDialog) builder.get_object("Save_File_Dialog");

      Save_File_Dialog.set_transient_for ((Window) this.CalcResult_TextView.get_toplevel());
      Save_File_Dialog.add_buttons (
        "_Cancel", Gtk.ResponseType.CANCEL,
        "_Save", Gtk.ResponseType.OK);

      // nur fix eigentlich sollte man buidler.connect_signals benutzen
      Save_File_Dialog.response.connect(Save_File_Dialog_Handler.saveResponse);

      Save_File_Dialog.run();

      Save_File_Dialog.destroy();
    }
    
    [CCode (instance_pos = -1)]
    public void on_PNGExport_Button_clicked(Button source) {

      var builder = new Builder();
      var PNG_Save_File_Dialog_Handler = new dialog.PNGSaveDialogHandler (this.Points,
        this.position,
        this.Diagram.get_allocated_width(),
        this.Diagram.get_allocated_height());
      
      try {
        builder.add_objects_from_file("PIDGui.glade", {"Save_File_Dialog"});
      } catch (Error e) {
        Posix.stderr.printf ("Could not load save file dialog: %s\n", e.message);
        exit(1);
      }
      //builder.connect_signals(Save_File_Dialog_Handler);
      
      var Save_File_Dialog = (FileChooserDialog) builder.get_object("Save_File_Dialog");

      Save_File_Dialog.set_transient_for ((Window) this.CalcResult_TextView.get_toplevel());
      Save_File_Dialog.add_buttons (
        "_Cancel", Gtk.ResponseType.CANCEL,
        "_Save", Gtk.ResponseType.OK);

      // nur fix eigentlich sollte man buidler.connect_signals benutzen
      Save_File_Dialog.response.connect(PNG_Save_File_Dialog_Handler.saveResponse);

      Save_File_Dialog.run();

      Save_File_Dialog.destroy();
    }
    
    [CCode (instance_pos = -1)]
    public void on_SVGExport_Button_clicked(Button source) {

      var builder = new Builder();
      var style_context = source.get_style_context();
      
      // set bg color
      var bgColor = style_context.get_background_color(source.get_state_flags());
      
      // set fg color
      var fgColor = style_context.get_color(source.get_state_flags());
      
      var PNG_Save_File_Dialog_Handler = new dialog.SVGSaveDialogHandler (this.Points,
        this.position,
        this.Diagram.get_allocated_width(),
        this.Diagram.get_allocated_height());
      
      try {
        builder.add_objects_from_file("PIDGui.glade", {"Save_File_Dialog"});
      } catch (Error e) {
        Posix.stderr.printf ("Could not load save file dialog: %s\n", e.message);
        exit(1);
      }
      //builder.connect_signals(Save_File_Dialog_Handler);
      
      var Save_File_Dialog = (FileChooserDialog) builder.get_object("Save_File_Dialog");

      Save_File_Dialog.set_transient_for ((Window) this.CalcResult_TextView.get_toplevel());
      Save_File_Dialog.add_buttons (
        "_Cancel", Gtk.ResponseType.CANCEL,
        "_Save", Gtk.ResponseType.OK);

      // nur fix eigentlich sollte man buidler.connect_signals benutzen
      Save_File_Dialog.response.connect(PNG_Save_File_Dialog_Handler.saveResponse);

      Save_File_Dialog.run();

      Save_File_Dialog.destroy();
    }
  }
}
