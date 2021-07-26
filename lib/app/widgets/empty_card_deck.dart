import 'package:flutter/material.dart';
import 'package:solitaire_flutter/app/widgets/card_column.dart';
import 'package:solitaire_flutter/models/playing_card.dart';
import 'package:solitaire_flutter/app/widgets/pickable_card.dart';

import '../../utils/utils.dart';

// The deck of cards which accept the final cards (Ace to King)
class EmptyCardDeck extends StatefulWidget {
  final CardSuit cardSuit;
  final List<PlayingCard> cardsAdded;
  final CardAcceptCallback onCardAdded;

  const EmptyCardDeck({
    Key? key,
    required this.cardSuit,
    required this.cardsAdded,
    required this.onCardAdded,
  }) : super(key: key);

  @override
  _EmptyCardDeckState createState() => _EmptyCardDeckState();
}

class _EmptyCardDeckState extends State<EmptyCardDeck> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2 * 57,
      height: 2 * 89,
      child: DragTarget<Map>(
        builder: (context, listOne, listTwo) {
          return widget.cardsAdded.isEmpty
              ? Opacity(
                  opacity: 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(child: suitToImage(widget.cardSuit, scale: 15))
                        ],
                      ),
                    ),
                  ),
                )
              : PickableCard(
                  playingCard: widget.cardsAdded.last,
                  attachedCards: [widget.cardsAdded.last],
                );
        },
        onWillAccept: (value) {
          PlayingCard cardAdded = value!["cards"].last;

          if (cardAdded.suit == widget.cardSuit) {
            if (CardType.values.indexOf(cardAdded.type) ==
                widget.cardsAdded.length) {
              return true;
            }
          }

          return false;
        },
        onAccept: (value) {
          widget.onCardAdded(
            value["cards"],
            value["fromIndex"],
          );
        },
      ),
    );
  }
}
