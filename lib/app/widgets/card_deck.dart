import 'package:flutter/material.dart';
import '../../models/playing_card.dart';
import 'empty_deck_indicator.dart';
import 'card/pickable_card.dart';

/// A basic card deck
class CardDeck extends StatefulWidget {
  final List<PlayingCard> cards;

  const CardDeck({Key? key, required this.cards}) : super(key: key);

  @override
  _CardDeckState createState() => _CardDeckState();
}

class _CardDeckState extends State<CardDeck> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const EmptyDeckIndicator(),
        if (widget.cards.length > 1)
          PickableCard(
            card: widget.cards[widget.cards.length - 2],
            isDraggable: false,
            parent: widget.cards,
          ),
        if (widget.cards.isNotEmpty)
          PickableCard(
            card: widget.cards.last,
            isDraggable: true,
            parent: widget.cards,
          )
      ],
    );
  }
}
