import 'dart:async';
import 'package:flutter/material.dart';
import 'maze.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Mazegen',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomePage(),
      );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _maze = Maze(30, 30);
  Iterator<Cell>? _iterator;

  @override
  void initState() {
    super.initState();
    go();
  }

  void go() {
    _iterator = _maze.generate().iterator;
    Timer.periodic(Duration(milliseconds: 1), onTick);
  }

  void onTick(Timer timer) {
    if (_iterator!.moveNext()) {
      //var visited = _iterator.current;
      setState(() {});
      //debugPrint('visited: ${visited.row}, ${visited.col}');
    } else {
      timer.cancel();
      _iterator = null;
      setState(() {});
      //debugPrint('done');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(title: Text('Mazegen')),
        floatingActionButton: FloatingActionButton(
            onPressed: _iterator == null ? go : null,
            child: Icon(Icons.directions_run)),
        body: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Column(
              children: [
                for (var row = 0; row != _maze.rows; ++row)
                  Expanded(
                    child: Row(
                      children: [
                        for (var col = 0; col != _maze.cols; ++col)
                          Expanded(
                            child: CellView(_maze.getCell(row, col)),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

class CellView extends StatelessWidget {
  final Cell cell;
  CellView(this.cell);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: _getBorderSide(Wall.top),
          left: _getBorderSide(Wall.left),
          right: _getBorderSide(Wall.right),
          bottom: _getBorderSide(Wall.bottom),
        ),
        color: cell.visited ? Colors.white : Colors.black,
      ),
    );
  }

  BorderSide _getBorderSide(Wall wall) => BorderSide(
      width: 5.0,
      style: cell.wallsUp[wall.index] ? BorderStyle.solid : BorderStyle.none);
}
