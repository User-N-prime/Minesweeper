import de.bezier.guido.*;

public int ROWS = 16;
public int COLS = 30;
public int HOVER_ROW = -1;
public int HOVER_COL = -1;

public boolean firstClick = true;

public int time = 0;
public int elapsed = 0;
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
  updateHover();
    // win/lose
  if (gameOver) {
 
    textSize(40);
    fill(255);
 
    if (win) {
      text("YOU WIN!", 226, 60);
      text("Time: " + elapsed, 678, 60);
    } else {
      text("GAME OVER", width/2, 60);
      revealAllMines();
    }
  }
 
  else {
  // time ticker
  if (!firstClick) {
    elapsed = (int)((millis() - time) / 1000);
  }

  fill(255);
  textSize(16);
  text("Time: " + elapsed, 226, 50);
  text("Mines left: " + (99 - numFlag), 678, 50);
  }
}

public void updateHover() {
    int row = (mouseX - 2) / 30;
    int col = (mouseY - 100) / 30;
    if (onGrid(row, col)) {
        HOVER_ROW = row;
        HOVER_COL = col;
    }
    else {
        HOVER_ROW = -1;
        HOVER_COL = -1;
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
   
    public void mousePressed (){
        press(mouseButton);
    }

    public void press(int whichButton) {
      if (gameOver) return;
    
      if (whichButton == LEFT && !flag) {
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
                  if (onGrid(r, c)) {
                    if (grid[r][c].mine && !grid[r][c].flag)
                      gameOver = true;
                  }
                }
              }
            }
          }
        }
        // normal reveal / mine hit
        else if (mine) {
          gameOver = true;
        } else {
          reveal(row, col);
          checkWin();
        }
      }
    
      // RIGHT click behavior (toggle flag)
      else if (whichButton == RIGHT && !on) {
        flag = !flag;
        if (flag) numFlag++;
        else numFlag--;
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

      if (row == HOVER_ROW && col = HOVER_COL) {
          fill(200);
          rect(x, y, width, height);
      }
      if (flag) {
        fill(242, 240, 80);
        rect(x, y, width, height);
        fill(0);
        textSize(12);

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

public void keyPressed() { 
    if (gameOver) return; 
    if (!onGrid(hoverRow, hoverCol)) return; 
    SimpleButton cell = grid[hoverRow][hoverCol]; 
    if (key == 'f' || key == 'F') { 
        cell.press(RIGHT); return;
    }
    if (key == 'e' || key == 'E') { 
        cell.press(LEFT); return; 
    } 
}
