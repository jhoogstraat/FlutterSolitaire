import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_flutter/utils/utils.dart';

import '../../models/playing_card.dart';
import '../screens/game_screen.dart';
import 'card/pickable_card.dart';

// This is a stack of overlayed cards (implemented using a stack)
class CardColumn extends StatefulWidget {
  // List of cards in the stack
  final List<PlayingCard> cards;

  // Callback to decide if dragged cards are accepted
  final WillAcceptCardCallback? willAcceptDrop;

  // Callback when cards are added to the stack
  final CardAcceptCallback? onCardsAdded;

  const CardColumn({
    Key? key,
    required this.cards,
    this.willAcceptDrop,
    this.onCardsAdded,
  })  : assert((willAcceptDrop == null) == (onCardsAdded == null)),
        super(key: key);

  @override
  _CardColumnState createState() => _CardColumnState();
}

class _CardColumnState extends State<CardColumn> {
  PlayingCard? draggedCard;

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
      return ColumnSuper(
        innerDistance: 23 - CardSizeProvider.of(context).height,
        children: [
          // max() required if length == 0
          ...widget.cards.sublist(0, max(0, widget.cards.length - 1)).map(
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

          if (widget.onCardsAdded == null)
            PickableCard(card: widget.cards.last, parent: widget.cards),

          if (widget.onCardsAdded != null)
            DragTarget<Map>(
              builder: (context, listOne, listTwo) {
                return widget.cards.isEmpty
                    ? SizedBox(
                        width: cardSize.width,
                        height: cardSize.height,
                      )
                    : PickableCard(
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
                return widget.willAcceptDrop!(
                  cards: value!["cards"],
                  destination: widget.cards,
                );
              },
              onAccept: (value) {
                widget.onCardsAdded!(
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
