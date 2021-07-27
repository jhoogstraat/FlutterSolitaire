import 'package:flutter/material.dart';
import 'package:solitaire_flutter/app/screens/game_screen.dart';
import 'package:solitaire_flutter/models/playing_card.dart';

import 'card_painter.dart';

class AnimatedCard extends StatefulWidget {
  final PlayingCard card;

  const AnimatedCard({Key? key, required this.card}) : super(key: key);

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  @override
  Widget build(BuildContext context) {
    final cardSize = CardSizeProvider.of(context);
    return SizedBox(
      width: cardSize.width,
      height: cardSize.height,
      child: CustomPaint(
        willChange: false,
        painter: CardPainter(widget.card),
      ),
    );
  }
}
