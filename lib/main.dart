import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'maze.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;

void _desktopInitHack() {
  bool isWeb = identical(0, 0.0);
  if (isWeb) return;

  if (Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  } else if (Platform.isFuchsia) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  _desktopInitHack();
  runApp(MyApp());
}

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
  final _maze = Maze(10, 10);
  Timer _timer;
  Iterable<RowCol> _generator;

  @override
  void initState() {
    super.initState();
    _generator = _maze.generate();
    _timer = Timer.periodic(Duration(milliseconds: 1), onTic);
  }

  void onTic(Timer timer) {
    var visited = _generator.first;
    if (visited != null) {
      debugPrint('visited: ${visited.row}, ${visited.col}');
      setState(() {});
    } else {
      debugPrint('done');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(title: Text('Mazegen')),
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
                            child: Cell(_maze, row, col),
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

class Cell extends StatelessWidget {
  final Maze maze;
  final int row;
  final int col;

  Cell(this.maze, this.row, this.col);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(style: _getBorderStyle(Wall.top)),
          left: BorderSide(style: _getBorderStyle(Wall.left)),
          right: BorderSide(style: _getBorderStyle(Wall.right)),
          bottom: BorderSide(style: _getBorderStyle(Wall.bottom)),
        ),
        color: Colors.grey.shade200,
      ),
    );
  }

  BorderStyle _getBorderStyle(Wall wall) =>
      maze.getCell(row, col).wallsUp[wall.index] ? BorderStyle.solid : BorderStyle.none;
}
