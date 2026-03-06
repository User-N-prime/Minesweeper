import de.bezier.guido.*;
import java.util.Collections;

public int ROWS = 16;
public int COLS = 30;
public int TOTAL_MINES = 99;

public boolean firstClick = true;

public int time = 0;
public int elapsed = 0;
public int numFlag = 0;

public boolean gameOver = false;
public boolean win = false;

public SimpleButton button;
public SimpleButton[][] grid = new SimpleButton[ROWS][COLS];

public ResetButton reButt;

public void setup (){
  size(904, 580);
  textAlign(CENTER, CENTER);
  
      Interactive.make( this );
  
  // make 30x16 game grid
  int w = 28;
  for ( int ix = 2, col = 0; ix < width - 4; ix += 30, col++) {
    for ( int iy = 100, row = 0; iy < height - 1; iy += 30, row++) {
      grid[row][col] = new SimpleButton( ix, iy, w, w, row, col);
    }
  }
  
  reButt = new ResetButton(407, 30, 90, 40);

}

public void draw (){
  background(0);
     
    // win/lose
    if (gameOver) {
  
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        if (grid[r][c] != null) {
          grid[r][c].draw();
        }
      }
    }
  
    if (reButt != null) {
        reButt.draw();
    }
  
    // win/lose messages
    if (gameOver) {
      textSize(40);
      fill(255);
      
      if (win) {
        text("YOU WIN!", 226, 60);
        text("Time: " + elapsed, 678, 60);
      } 
      else {
        text("GAME OVER", width/2, 60);
        revealAllMines();
      }
    }
  
    } 
  else {
    // time ticker
    if (!firstClick) {
      elapsed = (int)((millis() - time) / 1000);
    }
      // time ticker
      if (!firstClick) {
        elapsed = (int)((millis() - time) / 1000);
      }
  
    fill(255);
    textSize(16);
    text("Time: " + elapsed, 226, 50);
    text("Mines left: " + (TOTAL_MINES - numFlag), 678, 50);
    
    fill(255);
    textSize(16);
    text("Time: " + elapsed, 226, 50);
    text("Mines left: " + (TOTAL_MINES - numFlag), 678, 50);
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

 public boolean isInside(float mx, float my) {
    return mx >= x && mx <= x + width && my >= y && my <= y + height;
 }

  // called by manager

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
        
        if (numMines != 0) {
          fill(0);
          textSize(12);
          text(numMines, x + width/2, y + height/2);
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
      text("F", x + width/2, y + height/2);
    }
    
    if (mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height) {
      noFill();
      stroke(255);
      rect(x, y, width, height);
      noStroke();
    }
    
  }
}

// button that resets game
public class ResetButton {
  int x, y, w, h;
  
  public ResetButton(int xx, int yy, int ww, int hh) {
    x = xx;
    y = yy;
    w = ww;
    h = hh;
  
    Interactive.add(this);
  }

 public boolean isInside(float mx, float my) {
    return mx >= x && mx <= x + width && my >= y && my <= y + height;
 }

  void draw() {
    fill(175);
    rect(x, y, w, h);
    
    fill(0);
    textSize(16);
    text("RESET", x + w/2, y + h/2);
  }

}

// get what tile mouse hover over
public SimpleButton getHoveredTile() {

  int col = (int)((mouseX - 2) / 30);
  int row = (int)((mouseY - 100) / 30);
  
  if (onGrid(row, col)) {
    return grid[row][col];
  }

  return null;
}

// if clicked on ResetButton, reset game
// else, use getHoveredTile() to reveal/flag tiles with left/right mouse click
public void mousePressed() {
  if (mouseX >= reButt.x && mouseX <= reButt.x + reButt.w && mouseY >= reButt.y && mouseY <= reButt.y + reButt.h) {
    resetGame();
    return;
  }

  if (gameOver) return;
  
  SimpleButton cell = getHoveredTile();
  if (cell == null) return;
  
  // left mouse click -> reveal tile
  if (mouseButton == LEFT && !cell.flag) {
    bigReveal(cell);
  }
  
  // right mouse click -> flag
  if (mouseButton == RIGHT && !cell.on) {
    toggleFlag(cell);
  }
}

// use getHoveredTile() to reveal/flag tiles with e/f
public void keyPressed() {
  if (gameOver) return;
  
  SimpleButton cell = getHoveredTile();
  if (cell == null) return;
  
  // d -> reveal
  if ((key == 'd' || key == 'D') && !cell.flag) {
    bigReveal(cell);
  }
  
  // f -> flag
  if (key == 'f' || key == 'F') {
    toggleFlag(cell);
  }
}

// check if given [r][c] actually on minefield
public boolean onGrid(int row, int col){
  return (row >= 0 && row < ROWS && col >= 0 && col < COLS);
}

public void placeMines(SimpleButton firstCell) {
  ArrayList<SimpleButton> cells = new ArrayList<SimpleButton>();
  
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      if (Math.abs(firstCell.row - r) > 1 || Math.abs(firstCell.col - c) > 1)
        cells.add(grid[r][c]);
    }
  }
  
  Collections.shuffle(cells);
  
  for (int i = 0; i < TOTAL_MINES; i++) {
    cells.get(i).mine = true;
  }

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

// reveals a tile on minefield
// if tile has no neighboring mines -> reveal surrounding tiles using recursion
// stopAtMine prevents mines revealed during flood-fill
public void reveal(int row, int col, boolean stopAtMine) {
  if (!onGrid(row, col)) return;
  
  SimpleButton cell = grid[row][col];
  
  if (cell.on || cell.flag) return;
  
  if (stopAtMine && cell.mine) return;
  
  cell.on = true;
  
  if (countMines(row, col) == 0) {
  
    for (int r = row - 1; r <= row + 1; r++) {
      for (int c = col - 1; c <= col + 1; c++) {
  
        if (!(r == row && c == col)) {
          reveal(r, c, stopAtMine);
        }
  
     }
    }
  
  }
}

// handles tile clicks
//places mines on the first click,
// performs chord-reveal for numbered tiles, or reveals the tile normally
public void bigReveal(SimpleButton cell) {
  // place mines and start timer on first mouse click
  if (!cell.flag) {
    
    if (firstClick) {
      placeMines(cell);
      firstClick = false;
      time = millis();
    }
  
  }
  // can click revealed tiles to clear out 3x3 surrounding if # mines = # toggleFlag
  if (cell.on && countMines(cell.row, cell.col) > 0) {
    if (countFlags(cell.row, cell.col) == countMines(cell.row, cell.col)) {
  
      for (int r = cell.row - 1; r <= cell.row + 1; r++) {
        for (int c = cell.col - 1; c <= cell.col + 1; c++) {
  
          if (r != cell.row || c != cell.col) {
            reveal(r, c, false);
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
  
  if (cell.mine && !cell.on) {
    gameOver = true;
  }
  else {
    reveal(cell.row, cell.col, true);
    checkWin();
  }
}

public void toggleFlag(SimpleButton cell) {
  if (!cell.on) {
  cell.flag = !cell.flag;
  if (cell.flag) numFlag++;
  else numFlag--;
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
  
  if (revealed == ROWS * COLS - TOTAL_MINES) {
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

public void resetGame() {
  firstClick = true;
  
  time = 0;
  elapsed = 0;
  numFlag = 0;
  
  gameOver = false;
  win = false;
  
  int w = 28;
  for (int ix = 2, col = 0; ix < width - 4; ix += 30, col++) {
    for (int iy = 100, row = 0; iy < height - 1; iy += 30, row++) {
     grid[row][col] = new SimpleButton(ix, iy, w, w, row, col);
    }
  }
}
