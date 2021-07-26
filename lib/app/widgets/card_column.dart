import 'package:flutter/material.dart';
import 'package:solitaire_flutter/models/playing_card.dart';
import 'package:solitaire_flutter/app/widgets/pickable_card.dart';

typedef CardAcceptCallback = void Function(
    List<PlayingCard> card, int fromIndex);

// This is a stack of overlayed cards (implemented using a stack)
class CardColumn extends StatefulWidget {
  // List of cards in the stack
  final List<PlayingCard> cards;

  // Callback when card is added to the stack
  final CardAcceptCallback onCardsAdded;

  // The index of the list in the game
  final int columnIndex;

  const CardColumn({
    Key? key,
    required this.cards,
    required this.onCardsAdded,
    required this.columnIndex,
  }) : super(key: key);

  @override
  _CardColumnState createState() => _CardColumnState();
}

class _CardColumnState extends State<CardColumn> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<Map>(
      builder: (context, listOne, listTwo) {
        return SizedBox(
          width: 2 * 57,
          height: 2 * 89 + 43 * (widget.cards.length.toDouble() - 1),
          child: Stack(
            children: widget.cards.map((card) {
              final index = widget.cards.indexOf(card);
              return Positioned(
                top: index * 43,
                child: PickableCard(
                  playingCard: card,
                  attachedCards:
                      widget.cards.sublist(index, widget.cards.length),
                  columnIndex: widget.columnIndex,
                ),
              );
            }).toList(),
          ),
        );
      },
      onWillAccept: (value) {
        // If empty, accept
        if (widget.cards.isEmpty) {
          return true;
        }

        // Get dragged cards list
        List<PlayingCard> draggedCards = value!["cards"];
        PlayingCard firstCard = draggedCards.first;
        if (firstCard.color == CardColor.red) {
          if (widget.cards.last.color == CardColor.red) {
            return false;
          }

          int lastColumnCardIndex =
              CardType.values.indexOf(widget.cards.last.type);
          int firstDraggedCardIndex = CardType.values.indexOf(firstCard.type);

          if (lastColumnCardIndex != firstDraggedCardIndex + 1) {
            return false;
          }
        } else {
          if (widget.cards.last.color == CardColor.black) {
            return false;
          }

          int lastColumnCardIndex =
              CardType.values.indexOf(widget.cards.last.type);
          int firstDraggedCardIndex = CardType.values.indexOf(firstCard.type);

          if (lastColumnCardIndex != firstDraggedCardIndex + 1) {
            return false;
          }
        }
        return true;
      },
      onAccept: (value) {
        widget.onCardsAdded(
          value["cards"],
          value["fromIndex"],
        );
      },
    );
  }
}
