import 'package:flutter/material.dart';
import '../../screens/game_screen.dart';
import '../card_column.dart';
import '../../../models/playing_card.dart';
import 'card_painter.dart';

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
