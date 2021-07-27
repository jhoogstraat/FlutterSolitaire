import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:solitaire_flutter/models/playing_card.dart';
import 'package:solitaire_flutter/utils/utils.dart';

class CardPainter extends CustomPainter {
  final PlayingCard card;

  CardPainter(this.card);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromLTRBR(
        0, 0, size.width, size.height, const Radius.circular(5));
    canvas.drawRRect(rect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (card.faceUp) {
      final text = TextPainter(
        text: TextSpan(
          text: cardTypeToString(card),
          style: TextStyle(color: Colors.black, fontSize: size.width / 4),
        ),
        textDirection: TextDirection.ltr,
      );

      text.layout(maxWidth: size.width);

      text.paint(canvas, const Offset(3, 3));

      // Small image
      final smallSize = size.width / 3;
      paintImage(
        canvas: canvas,
        rect:
            Rect.fromLTWH(size.width - smallSize - 3, 3, smallSize, smallSize),
        image: suitCache[card.suit]!,
      );

      // Big image
      final bigSize = size.width / 1.5;
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(size.width / 2 - bigSize / 2,
            size.height - bigSize - 8, bigSize, bigSize),
        image: suitCache[card.suit]!,
      );
    } else {
      final deflatedRect = rect.deflate(3);
      canvas.drawRRect(
        deflatedRect,
        Paint()
          ..color = Colors.blue.shade900
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      final moreDeflatedRect = deflatedRect.deflate(3);
      canvas.drawRRect(moreDeflatedRect, Paint()..color = Colors.blue.shade900);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
