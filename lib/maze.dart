import 'dart:math';

class RowCol {
  final int row;
  final int col;
  RowCol(this.row, this.col);
}

enum Wall {
  top,
  right,
  bottom,
  left,
}

class Cell {
  final int row;
  final int col;
  var visited = false;
  var wallsUp = List<bool>(Wall.values.length);

  Cell(this.row, this.col) {
    for (var i = 0; i != wallsUp.length; ++i) wallsUp[i] = true;
  }
}

class Move {
  final Cell cellFrom;
  final Cell cellTo;

  Move(this.cellFrom, this.cellTo);
}

class Maze {
  final int rows;
  final int cols;
  final List<Cell> cells;
  final skippedMoves = List<Move>();
  final _rand = Random();

  // Translate 2D row, column pair into a 1D offset
  int _offset(int row, int col) => row * rows + col;

  Maze(this.rows, this.cols) : cells = List<Cell>(rows * cols) {
    for (var col = 0; col < cols; col++) {
      for (var row = 0; row < rows; row++) {
        cells[_offset(row, col)] = Cell(row, col);
      }
    }
  }

  Cell getCell(int row, int col) {
    assert(cells[_offset(row, col)].row == row);
    assert(cells[_offset(row, col)].col == col);
    return cells[_offset(row, col)];
  }

// A move is possible if
//      the cell is one of (a-1, b), (a+1, b), (a, b-1) or (a, b+1) and
//      the cell is not already visited and
//      the cell is not beyond the boundary.
  bool isPossibleMove(int row, int col) =>
      row >= 0 && row < rows && col >= 0 && col < cols && !getCell(row, col).visited;

/*
Maze Generation:
1.  Pick dimensions (handled in constructor).
2.  Pick starting point (a, b) where a is the row and b is the column.
3.  Mark (a, b) as "visited".
4.  Calculate possible moves where a move is possible if
        the cell is one of (a-1, b), (a+1, b), (a, b-1) or (a, b+1) and
        the cell is not already visited and
        the cell is not beyond the boundary.
5.  If there is a possible move,
        a) choose random move (c, d),
        b) add skipped moves to list
        c) knock down wall between (a, b) and (c, d).
        d) set (a, b) = (c, d) and goto 3.
6.  If there are no possible moves, check list of skipped moves
    for a "to" cell not already visited.
7.  If this is a skipped move,
        set (a, b) = where move was skipped from
        set (c, d) = where move was skipped to
        goto 5c.
8.  If there are no skipped moves, stop.
*/
  Iterable<RowCol> generate() sync* {
    // Choose random starting point (a, b).
    int a = _rand.nextInt(rows);
    int b = _rand.nextInt(cols);
    var havePlaceToMove = true;

    // If there are no more places to move, stop
    while (havePlaceToMove) {
      // Mark (a, b) as "visited"
      getCell(a, b).visited = true;

      // Notify any interested party
      yield RowCol(a, b);

      // Calculate possible moves; a move is possible if
      //   the cell is one of (a-1, b), (a+1, b), (a, b-1) or (a, b+1) and
      //   the cell is not already visited and
      //   the cell is not beyond the boundary
      var possibleMoves = List<RowCol>();
      if (isPossibleMove(a - 1, b)) possibleMoves.add(RowCol(a - 1, b)); // North
      if (isPossibleMove(a + 1, b)) possibleMoves.add(RowCol(a + 1, b)); // South
      if (isPossibleMove(a, b - 1)) possibleMoves.add(RowCol(a, b - 1)); // West
      if (isPossibleMove(a, b + 1)) possibleMoves.add(RowCol(a, b + 1)); // East

      // Where to move to
      int c;
      int d;

      // If there is a possible move from (a, b),
      if (possibleMoves.isNotEmpty) {
        //  Choose random move (c, d)
        var chosenMove = possibleMoves[_rand.nextInt(possibleMoves.length)];
        c = chosenMove.row;
        d = chosenMove.col;

        // Add skipped moves to list
        for (var skippedMove in possibleMoves.where((m) => !identical(m, chosenMove))) {
          var cellSkipped = getCell(skippedMove.row, skippedMove.col);
          skippedMoves.add(Move(getCell(a, b), cellSkipped));
        }
      }
      // If there are no possible moves from (a, b),
      // check list of skipped moves for a "to" cell not already visited.
      else {
        havePlaceToMove = false;

        for (var move in skippedMoves) {
          // If we haven't yet visited,
          //   set (a, b) = where move was skipped from
          //   set (c, d) = where move was skipped to
          if (!move.cellTo.visited) {
            a = move.cellFrom.row;
            b = move.cellFrom.col;
            c = move.cellTo.row;
            d = move.cellTo.col;

            havePlaceToMove = true;
            break;
          }
        }
      }

      if (havePlaceToMove) {
        // Figure out direction of from wall to knock down
        Wall wallFrom;
        if (d == b) {
          if (c > a)
            wallFrom = Wall.bottom;
          else
            wallFrom = Wall.top;
        } else {
          if (d > b)
            wallFrom = Wall.right;
          else
            wallFrom = Wall.left;
        }

        // NOTE: Must calculate cellFrom here and not above
        // because if there are no immediate moves, picking
        // a move from the list changes a and b.
        var cellFrom = getCell(a, b);

        // Knock down wall between (a, b) and (c, d)
        var cellTo = getCell(c, d);
        var wallTo = Wall.values[(wallFrom.index + 2) % Wall.values.length];

        cellFrom.wallsUp[wallFrom.index] = false;
        cellTo.wallsUp[wallTo.index] = false;

        // Set (a, b) = (c, d) and continue
        a = c;
        b = d;
      }
    }
  }
}
