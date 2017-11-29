using Gtk;
using Gdk;
using Posix;
using Cairo;

namespace dialog { 

  public class SVGSaveDialogHandler : Object {
    private Context context = null;
    private SvgSurface surface = null;
    private Gsl.Vector position = new Gsl.Vector (2);
    private List<double?> Points = new List<double?> ();
    private int width = 0;
    private int height = 0;
  
    public SVGSaveDialogHandler (List<double?> Points, Gsl.Vector Position, int x_size, int y_size) {
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
      var Save_File_Dialog = source as FileChooserDialog;
            
      switch (response) {
        case Gtk.ResponseType.OK:
                 
//          if ( "." in Save_File_Dialog.get_uri()){
//            Posix.stdout.printf("not appending\n");
//          } else {
//            Posix.stdout.printf("appending\n");
//            string tmp = Save_File_Dialog.get_filename()+".svg";
//            Posix.stdout.printf(tmp+"\n");
//            Save_File_Dialog.set_current_name(tmp);
//          }
          
          Posix.stdout.printf(Save_File_Dialog.get_uri()+"\n");
          Posix.stdout.printf(Save_File_Dialog.get_filename()+"\n");
          
          File file = File.new_for_uri (Save_File_Dialog.get_uri());
          
          if (file.query_exists()) {
            Posix.stdout.printf("File exists removing: %s\n", Save_File_Dialog.get_uri());
            try {
              file.delete ();
            } catch (Error e) {
              Posix.stderr.printf ("Could not delete output file stream: %s\n", e.message);
              exit(1);
            }
          }
          
          this.surface = new SvgSurface (Save_File_Dialog.get_filename(),
                                         this.width, this.height);
          this.context = new Context (this.surface);

          context.set_source_rgb (1,1,1);
          Background (context, this.width, this.height);
          context.set_source_rgb (0,0,0);
          Axies (context, this.position.get(0), this.position.get(1),
                 this.width, this.height);
          Graph (context, this.Points, this.position.get(0), this.position.get(1));
          
          break;
        case Gtk.ResponseType.CANCEL:
          break;
      }
    }
  }

  public class PNGSaveDialogHandler : Object {
    private Context context = null;
    private ImageSurface surface = null;
    private Gsl.Vector position = new Gsl.Vector (2);
    private List<double?> Points = new List<double?> ();
    private int width = 0;
    private int height = 0;
  
    public PNGSaveDialogHandler (List<double?> Points, Gsl.Vector Position, int x_size, int y_size) {
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
      var Save_File_Dialog = source as FileChooserDialog;
            
      switch (response) {
        case Gtk.ResponseType.OK:
          // show_help ();

          var file = File.new_for_uri (Save_File_Dialog.get_uri());
          
          if (file.query_exists()) {
            Posix.stdout.printf("File exists removing: %s", Save_File_Dialog.get_uri());
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
          
          context.set_source_rgba (1,1,1,1);
          Background (context, this.width, this.height);
          context.set_source_rgb (0,0,0);
          Axies (context, this.position.get(0), this.position.get(1),
                 this.width, this.height);
          Graph (context, this.Points, this.position.get(0), this.position.get(1));
          
          this.surface.write_to_png (Save_File_Dialog.get_filename());
          
          break;
        case Gtk.ResponseType.CANCEL:
          break;
      }
    }
  }

  public class SaveDialogHandler : Object {
    public string CSV { get; set; default=""; }
    
    public SaveDialogHandler (string csv) {
      this.CSV = csv;
    }
    
    [CCode (instance_pos = -1)]
    public void saveResponse(Dialog source, int response){
      var Save_File_Dialog = source as FileChooserDialog;
      
      switch (response) {
        case Gtk.ResponseType.OK:
          // show_help ();
          var file = File.new_for_uri(Save_File_Dialog.get_uri());
          FileOutputStream fileStream = null;
          DataOutputStream dos = null;
          
          
          if (file.query_exists()) {
            Posix.stdout.printf("File exists removing: %s", Save_File_Dialog.get_uri());
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
}
