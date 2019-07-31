import 'dart:math';

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
  final List<Cell> _cells;
  final _skippedMoves = List<Move>();
  final _rand = Random();

  // Translate 2D row, column pair into a 1D offset
  int _offset(int row, int col) => row * rows + col;

  Maze(this.rows, this.cols) : _cells = List<Cell>(rows * cols) {
    for (var col = 0; col < cols; col++) {
      for (var row = 0; row < rows; row++) {
        _cells[_offset(row, col)] = Cell(row, col);
      }
    }
  }

  Cell getCell(int row, int col) =>
      row < 0 || row >= rows || col < 0 || col >= cols ? null : _cells[_offset(row, col)];

  Cell _adjacentCell(Cell cellFrom, Wall wall) {
    switch (wall) {
      case Wall.top:
        return getCell(cellFrom.row - 1, cellFrom.col);
      case Wall.left:
        return getCell(cellFrom.row, cellFrom.col - 1);
      case Wall.bottom:
        return getCell(cellFrom.row + 1, cellFrom.col);
      case Wall.right:
        return getCell(cellFrom.row, cellFrom.col + 1);
      default:
        assert(false);
        return null;
    }
  }

  // Maze Generation
  Iterable<Cell> generate() sync* {
    // Choose cell at random starting point
    var cell = getCell(_rand.nextInt(rows), _rand.nextInt(cols));

    while (true) {
      // Mark current cell as "visited"
      cell.visited = true;

      // Notify any interested party
      yield cell;

      // Calculate possible cells to move to; a cell is possible to move to if
      //   the cell is adjacent in the top, left, bottom or right direction,
      //   the cell is not beyond the boundary and
      //   the cell is not already visited
      var possibleCellsTo = Wall.values
          .map((w) => _adjacentCell(cell, w))
          .where((c) => c != null && !c.visited)
          .toList();
      Move nextMove;

      // If there is a possible cell to move to from the current cell
      if (possibleCellsTo.isNotEmpty) {
        //  Choose random cell to move to
        nextMove = Move(cell, possibleCellsTo[_rand.nextInt(possibleCellsTo.length)]);

        // Remember possible moves we skipped for future consideration
        _skippedMoves.addAll(
            possibleCellsTo.where((c) => !identical(c, nextMove.cellTo)).map((c) => Move(cell, c)));
      }
      // If there are no possible moves from the current cell
      // check list of skipped moves for a "to" cell not already visited.
      else {
        nextMove = _skippedMoves.firstWhere((m) => !m.cellTo.visited, orElse: () => null);
      }

      // If there is a move
      if (nextMove != null) {
        // Figure out the walls to knock down
        var wallFrom = Wall.values
            .firstWhere((w) => identical(_adjacentCell(nextMove.cellFrom, w), nextMove.cellTo));
        var wallTo = Wall.values[(wallFrom.index + 2) % Wall.values.length];

        // Knock down wall between the cell we're moving from to the cell we're moving to
        nextMove.cellFrom.wallsUp[wallFrom.index] = false;
        nextMove.cellTo.wallsUp[wallTo.index] = false;

        // Do the move and continue
        cell = nextMove.cellTo;
      } else {
        // we're done
        break;
      }
    }
  }
}
