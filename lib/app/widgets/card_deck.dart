import 'package:flutter/material.dart';
import '../screens/game_screen.dart';
import 'card_column.dart';
import '../../models/playing_card.dart';
import 'pickable_card.dart';

/// Basic card deck
class CardDeck extends StatefulWidget {
  final int? id;
  final List<PlayingCard> cards;
  final CardAcceptCallback? onCardAdded;
  final bool isDragTarget;
  final bool isDraggable;

  const CardDeck({
    Key? key,
    required this.cards,
    this.id,
    this.onCardAdded,
    this.isDragTarget = true,
    this.isDraggable = true,
  }) : super(key: key);

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
            isDraggable: widget.isDraggable,
            parent: widget.cards,
          )
      ],
    );
  }
}

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
