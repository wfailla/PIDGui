using Gtk;
using Gdk;
using Posix;
using Cairo;

namespace dialog {

  public class SVGSaveDialogHandler : Object, gui.SaveDialogHandler {
    private Context context = null;
    private SvgSurface surface = null;
    private Gsl.Vector position = new Gsl.Vector (2);
    private List<double?> Points = new List<double?> ();
    private int width = 0;
    private int height = 0;
  
    public void SaveDialogHandler (List<double?> Points, Gsl.Vector Position, int x_size, int y_size) {
      Points.foreach ((entry) => {
        this.Points.append( entry );
      });
      this.position.set(0, Position.get(0));
      this.position.set(1, Position.get(1));
      this.width = x_size;
      this.height = y_size;
    }
    
    [CCode (instance_pos = -1)]
    public void saveResponse(Dialog source, int response) {
      var File_Dialog = source as FileChooserDialog;
            
      switch (response) {
        case Gtk.ResponseType.OK:
          Posix.stdout.printf("ok");
                 
//          if ( "." in File_Dialog.get_uri()){
//            Posix.stdout.printf("not appending\n");
//          } else {
//            Posix.stdout.printf("appending\n");
//            string tmp = File_Dialog.get_filename()+".svg";
//            Posix.stdout.printf(tmp+"\n");
//            File_Dialog.set_current_name(tmp);
//          }
          
          Posix.stdout.printf(File_Dialog.get_uri()+"\n");
          Posix.stdout.printf(File_Dialog.get_filename()+"\n");
          
          File file = File.new_for_uri (File_Dialog.get_uri());
          
          if (file.query_exists()) {
            Posix.stdout.printf("File exists removing: %s\n", File_Dialog.get_uri());
            try {
              file.delete ();
            } catch (Error e) {
              Posix.stderr.printf ("Could not delete output file stream: %s\n", e.message);
              exit(1);
            }
          }
          
          this.surface = new SvgSurface (File_Dialog.get_filename(),
                                         this.width, this.height);
          this.context = new Context (this.surface);
          
          gui.Renderer renderer = new drawer.simpleDraw();
      
          context.set_source_rgb (1,1,1);
          renderer.Background (context, this.width, this.height);
          context.set_source_rgb (0,0,0);
          renderer.Axies (context, this.position.get(0), this.position.get(1),
                 this.width, this.height);
          renderer.Graph (context, this.Points, this.position.get(0), this.position.get(1));
          
          break;
        case Gtk.ResponseType.CANCEL:
          Posix.stdout.printf("cancel");
          break;
      }
    }
  }

  public class PNGSaveDialogHandler : Object, gui.SaveDialogHandler {
    private Context context = null;
    private ImageSurface surface = null;
    private Gsl.Vector position = new Gsl.Vector (2);
    private List<double?> Points = new List<double?> ();
    private int width = 0;
    private int height = 0;
  
    public void SaveDialogHandler (List<double?> Points, Gsl.Vector Position, int x_size, int y_size) {
      Points.foreach ((entry) => {
        this.Points.append( entry );
      });
      this.position.set(0, Position.get(0));
      this.position.set(1, Position.get(1));
      this.width = x_size;
      this.height = y_size;
    }
    
    [CCode (instance_pos = -1)]
    public void saveResponse(Dialog source, int response) {
      var File_Dialog = source as FileChooserDialog;
            
      switch (response) {
        case Gtk.ResponseType.OK:
          Posix.stdout.printf("ok");
          // show_help ();

          var file = File.new_for_uri (File_Dialog.get_uri());
          
          if (file.query_exists()) {
            Posix.stdout.printf("File exists removing: %s", File_Dialog.get_uri());
            try {
              file.delete ();
            } catch (Error e) {
              Posix.stderr.printf ("Could not delete output file stream: %s\n", e.message);
              exit(1);
            }
          }

          this.surface = new ImageSurface (Cairo.Format.ARGB32, this.width,
                                           this.height);
          this.context = new Context (this.surface);
                   
          gui.Renderer renderer = new drawer.simpleDraw();
           
          context.set_source_rgba (1,1,1,1);
          renderer.Background (context, this.width, this.height);
          context.set_source_rgb (0,0,0);
          renderer.Axies (context, this.position.get(0), this.position.get(1),
                 this.width, this.height);
          renderer.Graph (context, this.Points, this.position.get(0), this.position.get(1));
          
          this.surface.write_to_png (File_Dialog.get_filename());
          
          break;
        case Gtk.ResponseType.CANCEL:
          Posix.stdout.printf("cancel");
          break;
      }
    }
  }

  public class CSVSaveDialogHandler : Object {
    public string CSV { get; set; default=""; }
    
    public CSVSaveDialogHandler (string csv) {
      this.CSV = csv;
    }
    
    [CCode (instance_pos = -1)]
    public void saveResponse(Dialog source, int response){
      var File_Dialog = source as FileChooserDialog;
      
      switch (response) {
        case Gtk.ResponseType.OK:
          // show_help ();
          var file = File.new_for_uri(File_Dialog.get_uri());
          FileOutputStream fileStream = null;
          DataOutputStream dos = null;
          
          
          if (file.query_exists()) {
            Posix.stdout.printf("File exists removing: %s", File_Dialog.get_uri());
            try {
              file.delete ();
            } catch (Error e) {
              Posix.stderr.printf ("Could not delete output file stream: %s\n", e.message);
              exit(1);
            }
          }
          
          try {
            fileStream = file.create(FileCreateFlags.PRIVATE);
          } catch (Error e) {
            Posix.stderr.printf ("Could not create output file stream: %s\n", e.message);
            exit(1);
          }
          
          dos = new DataOutputStream (fileStream);
          
          try {
            dos.put_string(this.CSV);
          } catch (Error e) {
            Posix.stderr.printf ("Could not put string in data output stream: %s\n", e.message);
            exit(1);
          }
          break;
        case Gtk.ResponseType.CANCEL:
          break;
      }
    }
  } 

  public class CSVOpenDialogHandler : Object {
    public List<double?> CSV = new List<double?> ();
    
    public CSVOpenDialogHandler () {}
    
    [CCode (instance_pos = -1)]
    public void openResponse(Dialog source, int response){
      var File_Dialog = source as FileChooserDialog;
      
      switch (response) {
        case Gtk.ResponseType.OK:
          // show_help ();
          var file = File.new_for_uri(File_Dialog.get_uri());
          if (!file.query_exists ()) {
            GLib.stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
            exit(1);
          }

          try {
            // Open file for reading and wrap returned FileInputStream into a
            // DataInputStream, so we can read line by line
            var dis = new DataInputStream (file.read ());
            string line;
            // Read lines until end of file (null) is reached
            while ((line = dis.read_line (null)) != null) {
              GLib.stdout.printf ("%s\n", line);
              this.CSV.append(double.parse(line));
            }
          } catch (Error e) {
            error ("%s", e.message);
            //exit(1);
          }
          break;
        case Gtk.ResponseType.CANCEL:
          break;
      }
    }
  } 
}
