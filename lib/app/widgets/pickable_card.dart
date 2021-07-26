import 'package:flutter/material.dart';
import '../screens/game_screen.dart';
import 'card_column.dart';
import '../../models/playing_card.dart';

import '../../utils/utils.dart';

// PickableCard makes the card draggable and translates it according to
// position in the column.
class PickableCard extends StatefulWidget {
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragCanceled;
  final bool isDraggable;
  final PlayingCard card;

  final List<PlayingCard> parent;
  final List<PlayingCard> attachedCards;

  const PickableCard({
    Key? key,
    required this.card,
    required this.parent,
    this.isDraggable = true,
    this.onDragStarted,
    this.onDragCanceled,
    this.attachedCards = const [],
  }) : super(key: key);

  @override
  _PickableCardState createState() => _PickableCardState();
}

class _PickableCardState extends State<PickableCard> {
  @override
  Widget build(BuildContext context) {
    final cardSize = CardSizeProvider.of(context);
    return SizedBox(
      width: cardSize.width,
      height: cardSize.height,
      child: !widget.card.faceUp || !widget.isDraggable
          ? CustomPaint(
              willChange: false,
              painter: CardPainter(widget.card),
            )
          : Draggable<Map>(
              child: CustomPaint(
                willChange: false,
                painter: CardPainter(widget.card),
              ),
              onDragStarted: widget.onDragStarted,
              onDraggableCanceled: (_, __) => widget.onDragCanceled?.call(),
              feedback: CardSizeProvider(
                width: cardSize.width,
                height: cardSize.height,
                spacing: cardSize.spacing,
                child: CardColumn(
                  cards: [widget.card, ...widget.attachedCards],
                ),
              ),
              childWhenDragging: const SizedBox(),
              data: {
                "source": widget.parent,
                "cards": [widget.card, ...widget.attachedCards],
              },
            ),
    );
  }
}

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
