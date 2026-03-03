import de.bezier.guido.*;

public int ROWS = 16;
public int COLS = 30;

public boolean firstClick = true;

public SimpleButton button;
public SimpleButton[][] grid = new SimpleButton[16][30];

public void setup ()
{
    size(904, 580);
    textAlign(CENTER, CENTER);
   
    // make the manager
   
    Interactive.make( this );
   
    // create some buttons
   
    int w = 28;
    for ( int ix = 2, col = 0; ix < width - 4; ix += 30, col++)
    {
        for ( int iy = 100, row = 0; iy < height - 1; iy += 30, row++)
        {
            grid[row][col] = new SimpleButton( ix, iy, w, w, row, col);
        }
    }
   
}

public void draw ()
{
    background(0);
}

public class SimpleButton
{
    float x, y, width, height;
    int row, col;
    boolean on;
    boolean flag = false;
    boolean mine = false;
   
    SimpleButton ( float xx, float yy, float w, float h, int r, int c)
    {
        x = xx; y = yy; width = w; height = h;
        row = r; col = c;
       
        Interactive.add( this ); // register it with the manager
    }
   
    // called by manager
   
    void mousePressed ()
    {
      if (mouseButton == LEFT && !flag) {
        if (firstClick) {
          placeMines(row, col);
          firstClick = false;
        }
       
        if (on && countMines(row, col) > 0) {
          if (countFlags(row, col) == countMines(row, col)) {
            for (int r = row - 1; r <= row + 1; r++) {
              for (int c = col - 1; c <= col + 1; c++) {
                if (r != row || c != col) {
                  numReveal(r, c);
                }
              }
            }
          }
        }
        else if (mine) {
          on = true;
        } else {
          reveal(row, col);
        }
      }
      if (mouseButton == RIGHT && !on)
      {
        flag = !flag;
      }
    }

    void draw ()
    {
      if (on)
      {
        if (mine)
        {
          fill(255, 0, 0);
          rect(x, y, width, height);
        }
        else
        {
          fill( 200 );
          rect(x, y, width, height);
          int numMines = countMines(row, col);
          if (numMines != 0)
          {
          fill(0);
          text(countMines(row, col), x + 15, y + 15);
          }
        }
      }
      else {
        fill( 100 );
        rect(x, y, width, height);
      }
     
      if (flag)
      {
        fill(242, 240, 80);
        rect(x, y, width, height);
        fill(0);
        text("F", x + 15, y + 15);
      }
    }
}

public boolean onGrid(int row, int col){
  return (row >= 0 && row < ROWS && col >= 0 && col < COLS);
}

public int countMines(int row, int col){
  int count = 0;
  for (int r = row - 1; r <= row + 1; r++) {
    for (int c = col - 1; c <= col + 1; c++) {
      if (onGrid(r, c) && !(r == row && c == col)) {
        if (grid[r][c].mine) {
          count++;
        }
      }
    }
  }
  return count;
}

public int countFlags(int row, int col){
  int count = 0;
  for (int r = row - 1; r <= row + 1; r++) {
    for (int c = col - 1; c <= col + 1; c++) {
      if (onGrid(r, c) && !(r == row && c == col)) {
        if (grid[r][c].flag) {
          count++;
        }
      }
    }
  }
  return count;
}

public void reveal(int row, int col) {
  if (!onGrid(row, col)) return;
 
  SimpleButton cell = grid[row][col];
 
  if (cell.on || cell.flag) return;
  if (cell.mine) return;
 
  cell.on = true;
 
  if (countMines(row, col) == 0) {
    for (int r = row - 1; r <= row + 1; r++) {
      for (int c = col - 1; c <= col + 1; c++) {
        if (!(r == row && c == col)) {
          reveal(r, c);
        }
      }
    }
  }
}

public void numReveal(int row, int col) {
  if (!onGrid(row, col)) return;
 
  SimpleButton cell = grid[row][col];
 
  if (cell.on || cell.flag) return;
 
  cell.on = true;
 
  if (countMines(row, col) == 0) {
    for (int r = row - 1; r <= row + 1; r++) {
      for (int c = col - 1; c <= col + 1; c++) {
        if (!(r == row && c == col) && !cell.mine) {
          reveal(r, c);
        }
      }
    }
  }
}

public void placeMines(int safeRow, int safeCol) {
  int mines = 99;

  while (mines > 0) {
    int r = (int)(Math.random() * ROWS);
    int c = (int)(Math.random() * COLS);

    if (!grid[r][c].mine) {
      if (Math.abs(r - safeRow) > 1 || Math.abs(c - safeCol) > 1) {
        grid[r][c].mine = true;
        mines--;
      }
    }
  }
}
