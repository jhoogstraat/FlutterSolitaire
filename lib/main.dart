import 'package:flutter/material.dart';
import 'app/screens/game_screen.dart';
import 'utils/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cacheSuits();
  runApp(const FlutterSolitaireApp());
}

class FlutterSolitaireApp extends StatelessWidget {
  const FlutterSolitaireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Solitaire',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}
