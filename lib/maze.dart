import 'dart:math';
import 'package:collection/collection.dart' show IterableExtension;

enum Wall { top, right, bottom, left }

class Cell {
  final int row;
  final int col;
  final wallsUp = List.filled(Wall.values.length, true);
  var visited = false;

  Cell(this.row, this.col);
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
  final _skippedMoves = <Move>[];
  final _rand = Random();

  // Translate (row, column) <=> index
  int _index(int row, int col) => row * cols + col;
  static int _row(int cols, int index) => index ~/ cols;
  static int _col(int cols, int index) => index % cols;

  Maze(this.rows, this.cols)
      : _cells = List.generate(rows * cols,
            ((index) => Cell(_row(cols, index), _col(cols, index))));

  Cell getCell(int row, int col) => _cells[_index(row, col)];

  Cell? _adjacentCell(Cell cellFrom, Wall wall) {
    switch (wall) {
      case Wall.top:
        return cellFrom.row - 1 < 0
            ? null
            : getCell(cellFrom.row - 1, cellFrom.col);
      case Wall.left:
        return cellFrom.col - 1 < 0
            ? null
            : getCell(cellFrom.row, cellFrom.col - 1);
      case Wall.bottom:
        return cellFrom.row + 1 > rows - 1
            ? null
            : getCell(cellFrom.row + 1, cellFrom.col);
      case Wall.right:
        return cellFrom.col + 1 > cols - 1
            ? null
            : getCell(cellFrom.row, cellFrom.col + 1);
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
      final possibleCellsTo = Wall.values
          .map((w) => _adjacentCell(cell, w))
          .where((c) => c != null && !c.visited)
          .map((c) => c!)
          .toList();
      Move? nextMove;

      // If there is a possible cell to move to from the current cell
      if (possibleCellsTo.isNotEmpty) {
        //  Choose random cell to move to
        nextMove =
            Move(cell, possibleCellsTo[_rand.nextInt(possibleCellsTo.length)]);

        // Remember possible moves we skipped for future consideration
        _skippedMoves.addAll(possibleCellsTo
            .where((c) => !identical(c, nextMove!.cellTo))
            .map((c) => Move(cell, c)));
      }
      // If there are no possible moves from the current cell
      // check list of skipped moves for a "to" cell not already visited.
      else {
        nextMove = _skippedMoves.firstWhereOrNull((m) => !m.cellTo.visited);
      }

      // If there is a move
      if (nextMove != null) {
        // Figure out the walls to knock down
        var wallFrom = Wall.values.firstWhere((w) =>
            identical(_adjacentCell(nextMove!.cellFrom, w), nextMove.cellTo));
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
