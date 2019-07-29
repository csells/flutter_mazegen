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
  final maze = Maze(5, 5);

  @override
  void initState() {
    super.initState();
    maze.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Mazegen')),
        body: Table(
          border: TableBorder.all(color: Colors.black),
          children: [
            for (var row = 0; row != maze.rows; ++row)
              TableRow(
                children: [
                  for (var col = 0; col != maze.cols; ++col)
                    TableCell(child: Container(color: Colors.red, width: 50, height: 50)),
                ],
              ),
          ],
        ),
      );
}
