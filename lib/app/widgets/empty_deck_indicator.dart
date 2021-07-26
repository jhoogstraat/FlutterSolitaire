import 'package:flutter/material.dart';
import 'package:solitaire_flutter/app/screens/game_screen.dart';

class EmptyDeckIndicator extends StatelessWidget {
  const EmptyDeckIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CardSizeProvider.of(context).width,
      height: CardSizeProvider.of(context).height,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Colors.white),
      ),
    );
  }
}
