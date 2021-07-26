import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

import '../../models/playing_card.dart';
import '../screens/game_screen.dart';
import 'pickable_card.dart';

typedef CardAcceptCallback = void Function(
    List<PlayingCard> cards, List<PlayingCard> source);

// This is a stack of overlayed cards (implemented using a stack)
class CardColumn extends StatefulWidget {
  // List of cards in the stack
  final List<PlayingCard> cards;

  // Callback when card is added to the stack
  final CardAcceptCallback? onCardsAdded;

  /// If this column accepts new cards
  final bool isDragTarget;

  const CardColumn({
    Key? key,
    required this.cards,
    this.onCardsAdded,
    this.isDragTarget = true,
  }) : super(key: key);

  @override
  _CardColumnState createState() => _CardColumnState();
}

class _CardColumnState extends State<CardColumn> {
  PlayingCard? draggedCard = null;

  @override
  Widget build(BuildContext context) {
    final cardSize = CardSizeProvider.of(context);

    if (widget.cards.contains(draggedCard)) {
      final index = widget.cards.indexOf(draggedCard!);

      if (index == 0) {
        return SizedBox(
          width: cardSize.width,
          height: cardSize.height,
        );
      }

      return ColumnSuper(
        innerDistance: 23 - cardSize.height,
        children: widget.cards
            .sublist(0, index)
            .map((e) => PickableCard(card: e, parent: widget.cards))
            .toList(),
      );
    } else {
      if (widget.cards.isEmpty) {
        return SizedBox(
          width: cardSize.width,
          height: cardSize.height,
        );
      }

      return ColumnSuper(
        innerDistance: 23 - CardSizeProvider.of(context).height,
        children: [
          ...widget.cards.sublist(0, widget.cards.length - 1).map(
                (card) => PickableCard(
                  card: card,
                  attachedCards: widget.cards.sublist(
                    widget.cards.indexOf(card) + 1,
                    widget.cards.length,
                  ),
                  parent: widget.cards,
                  onDragStarted: () {
                    setState(() => draggedCard = card);
                  },
                  onDragCanceled: () {
                    setState(() => draggedCard = null);
                  },
                ),
              ),
          if (!widget.isDragTarget)
            PickableCard(
              card: widget.cards.last,
              parent: widget.cards,
            )
          else
            DragTarget<Map>(
              builder: (context, listOne, listTwo) {
                return PickableCard(
                  card: widget.cards.last,
                  parent: widget.cards,
                  onDragStarted: () {
                    setState(() => draggedCard = widget.cards.last);
                  },
                  onDragCanceled: () {
                    setState(() => draggedCard = null);
                  },
                );
              },
              onWillAccept: (value) {
                // If empty, accept
                if (widget.cards.isEmpty) {
                  return true;
                }

                // Get dragged cards list
                List<PlayingCard> draggedCards = value!["cards"];
                final firstCard = draggedCards.first;
                if (firstCard.color == CardColor.red) {
                  if (widget.cards.last.color == CardColor.red) {
                    return false;
                  }

                  final lastColumnCardIndex =
                      CardType.values.indexOf(widget.cards.last.type);
                  final firstDraggedCardIndex =
                      CardType.values.indexOf(firstCard.type);

                  if (lastColumnCardIndex != firstDraggedCardIndex + 1) {
                    return false;
                  }
                } else {
                  if (widget.cards.last.color == CardColor.black) {
                    return false;
                  }

                  final lastColumnCardIndex =
                      CardType.values.indexOf(widget.cards.last.type);
                  final firstDraggedCardIndex =
                      CardType.values.indexOf(firstCard.type);

                  if (lastColumnCardIndex != firstDraggedCardIndex + 1) {
                    return false;
                  }
                }
                return true;
              },
              onAccept: (value) {
                widget.onCardsAdded?.call(
                  value["cards"],
                  value["source"],
                );
              },
            )
        ],
      );
    }
  }
}
