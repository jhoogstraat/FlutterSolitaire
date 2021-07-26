import 'package:flutter/material.dart';
import 'package:solitaire_flutter/app/screens/game_screen.dart';
import 'package:solitaire_flutter/app/widgets/card_column.dart';
import 'package:solitaire_flutter/models/playing_card.dart';

import '../../utils/utils.dart';

// PickableCard makes the card draggable and translates it according to
// position in the stack.
class PickableCard extends StatefulWidget {
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;
  final PlayingCard playingCard;

  final int? columnIndex;
  final List<PlayingCard> attachedCards;

  const PickableCard({
    Key? key,
    required this.playingCard,
    this.onDragStarted,
    this.onDragEnded,
    this.columnIndex,
    this.attachedCards = const [],
  }) : super(key: key);

  @override
  _PickableCardState createState() => _PickableCardState();
}

class _PickableCardState extends State<PickableCard> {
  @override
  Widget build(BuildContext context) {
    final size = CardSizeProvider.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: !widget.playingCard.faceUp
          ? _buildCard()
          : Draggable<Map>(
              child: _buildCard(),
              onDragStarted: widget.onDragStarted,
              onDragEnd: widget.onDragEnded != null
                  ? (_) => widget.onDragEnded!.call()
                  : null,
              feedback: CardColumn(
                cards: widget.attachedCards,
                columnIndex: 1,
                onCardsAdded: (card, position) {},
              ),
              childWhenDragging: SizedBox(), //_buildCardFaceUp(),
              data: {
                "cards": widget.attachedCards,
                "fromIndex": widget.columnIndex,
              },
            ),
    );
  }

  Widget _buildCard() {
    return CustomPaint(
      willChange: false,
      painter: CardPainter(widget.playingCard),
    );
  }

  Widget _buildCardFaceUp() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardTypeToString(widget.playingCard),
                // style: TextStyle(fontSize: 30.0),
              ),
              suitToImage(widget.playingCard.suit, scale: 30),
            ],
          ),
          suitToImage(widget.playingCard.suit, scale: 11),
        ],
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
        0, 0, size.width, size.height, const Radius.circular(10));
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
            style: const TextStyle(color: Colors.black, fontSize: 25),
          ),
          textDirection: TextDirection.ltr);
      text.layout(maxWidth: size.width);
      text.paint(canvas, const Offset(6, 6));
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(size.width - 44, 4, 40, 40),
        image: suitCache[card.suit]!,
      );
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(size.width / 2 - 40, size.height - 84, 80, 80),
        image: suitCache[card.suit]!,
      );
    } else {
      final deflatedRect = rect.deflate(5);
      canvas.drawRRect(
        deflatedRect,
        Paint()
          ..color = Colors.blue.shade900
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      final moreDeflatedRect = deflatedRect.deflate(5);
      canvas.drawRRect(moreDeflatedRect, Paint()..color = Colors.blue.shade900);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
