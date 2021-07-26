import 'package:flutter/material.dart';
import 'package:solitaire_flutter/app/screens/game_screen.dart';
import 'package:solitaire_flutter/utils/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cacheSuits();
  runApp(const FlutterSolitaireApp());
}

class FlutterSolitaireApp extends StatelessWidget {
  const FlutterSolitaireApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}
