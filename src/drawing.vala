using Cairo;

private void triangle (Context ctx, double x, double y, int rotation) {
  int SIZE = 10;
  
  ctx.new_path ();
  
  if ( y < (2 * SIZE) ) {
    if ( rotation < 0 ) {
      y = (2 * SIZE);
    }
  }
  
  if ( x <= 0 ) {
    if ( rotation > 0 ) {
      x = (2 * SIZE);
    }
  }
  
  ctx.translate (x, y);
  ctx.rotate (rotation * Math.PI / 180);
  
  ctx.move_to (SIZE, 0);
  ctx.rel_line_to (SIZE, 2 * SIZE);
  ctx.rel_line_to (-2 * SIZE, 0);
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
  
  if (posiX > width) {
    triangle(ctx, width, height/2, 90);
  } else if (posiX < 2) {
    triangle(ctx, 0, height/2, -90);
  } else {
    ctx.move_to(posiX, 10);
    ctx.line_to(posiX, height);
    ctx.stroke();
    triangle(ctx, posiX - 10, 0, 0);
  }
  
  if (posiY > height) {
    triangle(ctx, width/2, height, 180);
  } else if (posiY < 2) {
    triangle(ctx, width/2, 0, 0);
  } else {
    ctx.move_to(0, posiY);
    ctx.line_to(width-10, posiY);
    ctx.stroke();
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
  
  Points.foreach ((entry) => {
    ctx.line_to(Points.index (entry) * 10, -1 *entry);
  });
  
  ctx.stroke();
}
