import 'package:flutter/material.dart';
import '../../models/playing_card.dart';
import 'empty_deck_indicator.dart';
import 'pickable_card.dart';

/// A basic card deck
class AnimatedCardDeck extends StatefulWidget {
  final List<PlayingCard> cards;
  final VoidCallback? onTap;

  const AnimatedCardDeck({
    Key? key,
    required this.cards,
    this.onTap,
  }) : super(key: key);

  @override
  AnimatedCardDeckState createState() => AnimatedCardDeckState();
}

class AnimatedCardDeckState extends State<AnimatedCardDeck>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<Offset> offset;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    offset = Tween(
      begin: const Offset(-1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutExpo));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deck = Stack(
      children: [
        const EmptyDeckIndicator(),
        if (widget.cards.length > 1)
          PickableCard(
            card: widget.cards[widget.cards.length - 2],
            isDraggable: false,
            parent: widget.cards,
          ),
        if (widget.cards.isNotEmpty)
          SlideTransition(
            position: offset,
            child: PickableCard(
              card: widget.cards.last,
              isDraggable: true,
              parent: widget.cards,
            ),
          )
      ],
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: () {
          controller.forward(from: 0);
          widget.onTap?.call();
        },
        child: deck,
      );
    } else {
      return deck;
    }
  }
}
