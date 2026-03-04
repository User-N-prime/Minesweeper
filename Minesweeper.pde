import de.bezier.guido.*;

public int ROWS = 16;
public int COLS = 30;

public boolean firstClick = true;

public int time = 0;
public int numFlag = 0;

public boolean gameOver = false;
public boolean win = false;

public SimpleButton button;
public SimpleButton[][] grid = new SimpleButton[16][30];

public void setup (){
    size(904, 580);
    textAlign(CENTER, CENTER);
   
    Interactive.make( this );
   
    // make 30x16 game grid
   
    int w = 28;
    for ( int ix = 2, col = 0; ix < width - 4; ix += 30, col++)
    {
        for ( int iy = 100, row = 0; iy < height - 1; iy += 30, row++)
        {
            grid[row][col] = new SimpleButton( ix, iy, w, w, row, col);
        }
    }
   
}

public void draw (){
  background(0);
    int elapsed = 0;
    // win/lose
  if (gameOver) {
 
    textSize(40);
    fill(255);
 
    if (win) {
      text("YOU WIN!", 226, 60);
      text("Time: " + elapsed, 678, 60);
    } else {
      text("GAME OVER", width/2, 60);
    }
  }
 
  else {
  // time ticker
  if (!firstClick) {
    elapsed = (millis() - time) / 1000;
  }

  fill(255);
  textSize(16);
  text("Time: " + elapsed, 226, 50);
  text("Flags left: " + (99 - numFlag), 678, 50);
  }
}

public class SimpleButton{
    float x, y, width, height;
    int row, col;
    boolean on;
    boolean flag = false;
    boolean mine = false;
   
    SimpleButton ( float xx, float yy, float w, float h, int r, int c){
        x = xx; y = yy; width = w; height = h;
        row = r; col = c;
       
        Interactive.add( this ); // register it with the manager
    }
   
    // called by manager
   
    void mousePressed (){
      if (gameOver) return;
      // place mines and start timer on first mouse click
      if (mouseButton == LEFT && !flag) {
        if (firstClick) {
          placeMines(row, col);
          firstClick = false;
          time = millis();
        }
       // can click revealed tiles to clear out 3x3 surrounding if # mines = # flags
        if (on && countMines(row, col) > 0) {
          if (countFlags(row, col) == countMines(row, col)) {
            for (int r = row - 1; r <= row + 1; r++) {
              for (int c = col - 1; c <= col + 1; c++) {
                if (r != row || c != col) {
                  numReveal(r, c);
                  checkWin();
                }
              }
            }
          }
        }
        else if (mine) {
          on = true;
          gameOver = true;
          revealAllMines();
        } else {
          reveal(row, col);
          checkWin();
        }
      }
      // flag a tile
      if (mouseButton == RIGHT && !on){
        flag = !flag;
        // counts # flags
        if (flag)
          numFlag++;
        else
          numFlag--;
      }
    }

    void draw (){
      if (on){
        if (mine) {
          fill(255, 0, 0);
          rect(x, y, width, height);
        }
        else {
          fill( 200 );
          rect(x, y, width, height);
          int numMines = countMines(row, col);
          if (numMines != 0)
          {
          fill(0);
          textSize(12);
          text(numMines, x + 15, y + 15);
          }
        }
      }
      else {
        fill( 100 );
        rect(x, y, width, height);
      }
     
      if (flag) {
        fill(242, 240, 80);
        rect(x, y, width, height);
        fill(0);
        textSize(12);
public void checkWin() {
  int revealed = 0;
 
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      if (grid[r][c].on && !grid[r][c].mine)
        revealed++;
    }
  }
 
  if (revealed == ROWS * COLS - 99) {
    win = true;
    gameOver = true;
  }
}

public void revealAllMines() {
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      if (grid[r][c].mine) {
        grid[r][c].on = true;
      }
    }
  }
}
