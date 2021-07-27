import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solitaire_flutter/app/screens/game_screen.dart';
import 'package:solitaire_flutter/app/widgets/empty_deck_indicator.dart';
import 'package:solitaire_flutter/app/widgets/card/pickable_card.dart';
import 'package:solitaire_flutter/models/playing_card.dart';

class OffsetCard {
  Animation<Offset> animation;
  final PlayingCard card;
  final Animation<double> _parent;
  final Offset _finalDestination;
  bool isDraggable = true;

  OffsetCard(
      this.card, this._parent, Offset destination, this._finalDestination)
      : animation = Tween<Offset>(begin: Offset.zero, end: destination)
            .animate(_parent) {
    animation.addStatusListener(_onStatusUpdate);
  }

  void updateDestination(Offset destination) {
    animation = Tween<Offset>(
      begin: animation.value,
      end: destination,
    ).animate(_parent);
    animation.addStatusListener(_onStatusUpdate);
  }

  void _onStatusUpdate(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animation = AlwaysStoppedAnimation(animation.value);
    }
  }
}

class CardDrawer extends StatefulWidget {
  final List<PlayingCard> cards;

  const CardDrawer({Key? key, required this.cards}) : super(key: key);

  @override
  _CardDrawerState createState() => _CardDrawerState();
}

class _CardDrawerState extends State<CardDrawer>
    with SingleTickerProviderStateMixin {
  late final List<PlayingCard> cardsClosed;
  late final List<OffsetCard> cardsOpened;

  late final AnimationController animationController;
  late final Animation<double> animator;
  late final List<Offset> cardOffsets;

  @override
  void initState() {
    super.initState();
    cardsClosed = widget.cards;
    cardsOpened = <OffsetCard>[];

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    animator = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCirc,
    );

    cardOffsets = const [
      Offset(-2.0, 0),
      Offset(-1.6, 0),
      Offset(-1.2, 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cardSize = CardSizeProvider.of(context);
    final openDeckOffset = 2 * cardSize.width;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topRight,
      children: [
        const EmptyDeckIndicator(),
        Positioned(
          right: openDeckOffset,
          child: const EmptyDeckIndicator(),
        ),
        // Show the two topmost cards
        ...cardsClosed.sublist(cardsClosed.length - 2, cardsClosed.length).map(
            (card) => PickableCard(
                card: card, parent: cardsClosed, isDraggable: false)),
        SizedBox(
          width: cardSize.width,
          height: cardSize.height,
          child: GestureDetector(
            onTap: () {
              if (cardsClosed.isNotEmpty) {
                _openCard();
              } else {
                _closeAllCards();
              }
            },
          ),
        ),
        ...cardsOpened.map(
          (e) => SlideTransition(
            position: e.animation,
            child: PickableCard(
              card: e.card,
              parent: widget.cards,
              isDraggable: e.isDraggable,
            ),
          ),
        ),
      ],
    );
  }

  _closeAllCards() {
    setState(() {
      widget.cards.forEach((element) => element.faceUp = false);
      cardsClosed = widget.cards;
      cardsOpened.clear();
    });
  }

  _openCard() {
    setState(() {
      final card = cardsClosed.removeAt(cardsClosed.length - 1);
      card.faceUp = true;

      if (cardsOpened.isNotEmpty) {
        cardsOpened.last.isDraggable = false;
      }

      cardsOpened.add(
        OffsetCard(
          card,
          animator,
          cardOffsets[min(2, cardsOpened.length)],
          cardOffsets.first,
        ),
      );

      if (cardsOpened.length > 3) {
        cardsOpened.sublist(0, cardsOpened.length - 3).forEach((element) {
          if (element.animation.value != cardOffsets.first) {
            element.updateDestination(cardOffsets.first);
          }
        });

        var i = 0;
        cardsOpened
            .sublist(cardsOpened.length - 3, cardsOpened.length - 1)
            .forEach((element) {
          element.updateDestination(cardOffsets[i]);
          i++;
        });
      }
    });

    animationController.forward(from: 0);
  }
}
