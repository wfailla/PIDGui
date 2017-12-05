using Cairo;

namespace drawer {

  public class simpleDraw : Object, gui.Renderer {
    private int triangleSize = 10;
    private int ticHight = 4;
    private int ticWidth = 30;

    public int getTriangleSize () {
      return triangleSize;
    }
    public int getTicHight () {
      return ticHight;
    }
    public int getTicWidth () {
      return ticWidth;
    }
    
    public void setTriangleSize (int value) {
      triangleSize = value;
    }
    public void setTicHight (int value) {
      ticHight = value;
    }
    public void increaseTicWidth (int value) {
      ticWidth += value;
    }

    private void triangle (Context ctx, double x, double y, int rotation) {
      ctx.new_path ();

      if ( y < (2 * triangleSize) ) {
        if ( rotation < 0 ) {
          y = (2 * triangleSize);
        }
      }

      if ( x <= 0 ) {
        if ( rotation > 0 ) {
          x = (2 * triangleSize);
         }
      }

      ctx.translate (x, y);
      ctx.rotate (rotation * Math.PI / 180);

      ctx.move_to (triangleSize, 0);
      ctx.rel_line_to (triangleSize, 2 * triangleSize);
      ctx.rel_line_to (-2 * triangleSize, 0);
      ctx.fill ();
    
      ctx.rotate (-rotation * Math.PI / 180);
      ctx.translate (-x, -y);
    
      ctx.close_path ();
    }
    
    public void Background (Context ctx, double width, double height) {
      //ctx.set_source_rgba (0.75,0.75,0.75, 1);
      ctx.rectangle (0, 0, width, height);
      ctx.fill ();
    }
    
    public void Axies (Context ctx, double posiX, double posiY, double width,
                  double height) {
    
      ctx.set_line_width (1);
    
      // draw y-axies
    
      if (posiX > width) {
        triangle(ctx, width, height/2, 90);
      } else if (posiX < 2) {
        triangle(ctx, 0, height/2, -90);
      } else {
        ctx.move_to(posiX, 10);
        ctx.line_to(posiX, height);
        ctx.stroke();
    
        for (double i=1; i<(height/2); i++) {
          ctx.move_to (posiX + ticHight, posiY + this.ticWidth * i);
          ctx.line_to(posiX - ticHight, posiY + this.ticWidth * i);
          ctx.stroke();
          ctx.move_to (posiX + ticHight, posiY - this.ticWidth * i);
          ctx.line_to(posiX - ticHight, posiY - this.ticWidth * i);
          ctx.stroke();
        }
        
        triangle(ctx, posiX - 10, 0, 0);
      }
      
      // draw x-axies
    
      if (posiY > height) {
        triangle(ctx, width/2, height, 180);
      } else if (posiY < 2) {
        triangle(ctx, width/2, 0, 0);
      } else {
        ctx.move_to(0, posiY);
        ctx.line_to(width-10, posiY);
        ctx.stroke();
        
        for (double i=1; i<width; i++) {
          ctx.move_to (posiX + this.ticWidth * i, posiY + ticHight);
          ctx.line_to(posiX + this.ticWidth * i, posiY - ticHight);
          ctx.stroke();
          ctx.move_to (posiX - this.ticWidth * i, posiY + ticHight);
          ctx.line_to(posiX - this.ticWidth * i, posiY - ticHight);
          ctx.stroke();
        }
        
        triangle(ctx, width, posiY - 10, 90);
      }
    }
    
    public void Graph (Context ctx, List<double?> Points, double offsetX,
                  double offsetY) {
      ctx.translate(offsetX, offsetY);
    
      ctx.set_source_rgb (1, 0.5, 0);
      ctx.set_line_width (1);
      ctx.set_line_join (LineJoin.ROUND);
      ctx.move_to (0, 0);
    
    
      // add scale because the y values are high 
      Points.foreach ((entry) => {
        ctx.line_to(Points.index (entry) * this.ticWidth, -1 * entry * this.ticWidth);
      });
    
      ctx.stroke();
    }
  }
}
