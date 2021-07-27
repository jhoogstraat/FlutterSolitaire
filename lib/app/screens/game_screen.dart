import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_flutter/app/widgets/animated_card_deck.dart';
import 'package:solitaire_flutter/app/widgets/card/pickable_card.dart';
import 'package:solitaire_flutter/app/widgets/card_drawer.dart';
import '../widgets/card_column.dart';
import '../widgets/card_deck.dart';
import '../../models/game.dart';
import '../../models/playing_card.dart';

class CardSizeProvider extends InheritedWidget {
  const CardSizeProvider({
    Key? key,
    required Widget child,
    required this.width,
    required this.height,
    required this.spacing,
  }) : super(key: key, child: child);

  final double width;
  final double height;
  final double spacing;

  static CardSizeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CardSizeProvider>()!;
  }

  @override
  bool updateShouldNotify(CardSizeProvider oldWidget) {
    return true;
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Game game;
  final openCardDeck = GlobalKey<AnimatedCardDeckState>();

  @override
  void initState() {
    super.initState();
    game = Game.klondike();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/backgrounds/bg_01.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Solitaire"),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: () => setState(() => game = Game.klondike()),
                icon: const Icon(Icons.refresh))
          ],
        ),
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = min(constraints.maxWidth, constraints.maxHeight) /
                    game.cardColumns.length -
                5;
            final height = width * 1.56;
            final spacing = 5 / (game.cardColumns.length + 1);
            return CardSizeProvider(
              width: width,
              height: height,
              spacing: spacing,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Final decks
                          for (final deck in game.finalDecks)
                            DragTarget<Map>(
                              builder: (context, listOne, listTwo) {
                                return CardDeck(cards: deck);
                              },
                              onWillAccept: (value) {
                                return _willAcceptCardsOnFinalDeck(
                                  deck: deck,
                                  cards: value!["cards"],
                                );
                              },
                              onAccept: (value) {
                                final List<PlayingCard> cards = value["cards"];
                                final List<PlayingCard> source =
                                    value["source"];
                                deck.addAll(cards);
                                cards.forEach(source.remove);
                                // Turn new last card in column
                                if (source.isNotEmpty) {
                                  source.last.faceUp = true;
                                }
                                _refreshState();
                              },
                            ),

                          // Spacer
                          SizedBox(width: width, height: height),
                          SizedBox(width: width, height: height),
                          SizedBox(width: width, height: height),
                        ],
                      ),
                      // Decks for drawing cards
                      Positioned(
                        right: 9,
                        child: SizedBox(
                          width: 3 * width + 2 * spacing,
                          child: CardDrawer(cards: game.cardDeckClosed),
                        ),
                      )
                    ],
                  ),

                  // Spacer
                  const SizedBox(height: 30.0),

                  // Card Columns
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: game.cardColumns
                        .map(
                          (column) => CardColumn(
                            cards: column,
                            willAcceptDrop: _willAcceptCardsOnColumn,
                            onCardsAdded: (cards, source) {
                              column.addAll(cards);
                              cards.forEach(source.remove);
                              if (source.isNotEmpty) {
                                source.last.faceUp = true;
                              }
                              _refreshState();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openCardFromDeck() async {
    if (game.cardDeckClosed.isEmpty) {
      game.cardDeckClosed.addAll(game.cardDeckOpened);
      for (final card in game.cardDeckClosed) {
        card.faceUp = false;
      }
      game.cardDeckOpened.clear();
    } else {
      game.cardDeckOpened.add(game.cardDeckClosed.removeLast()..faceUp = true);
    }

    setState(() {});

    openCardDeck.currentState!.controller.forward(from: 0);
  }

  bool _willAcceptCardsOnFinalDeck({
    required List<PlayingCard> cards,
    required List<PlayingCard> deck,
  }) {
    // Only accept one card at a time
    if (cards.length != 1) {
      return false;
    }

    final card = cards.last;

    // Only ace allowed on empty deck
    if (deck.isEmpty) {
      return card.type == CardType.ace;
    }

    // Otherwise card suit has to match last card suit in the deck and
    /// type has to be the type following the last card type in the deck
    return card.suit == deck.last.suit &&
        CardType.values.indexOf(card.type) == deck.length;
  }

  bool _willAcceptCardsOnColumn({
    required List<PlayingCard> cards,
    required List<PlayingCard> destination,
  }) {
    // If empty, only accept if king is first
    if (destination.isEmpty) {
      return cards.first.type == CardType.king;
    }
    print(destination.last.color);
    print(destination.last.type);

    print("cards ${cards.length} column ${destination.length}");

    // Get dragged cards list
    final firstCard = cards.first;
    if (firstCard.color == CardColor.red) {
      if (destination.last.color == CardColor.red) {
        return false;
      }

      final lastColumnCardIndex =
          CardType.values.indexOf(destination.last.type);
      final firstDraggedCardIndex = CardType.values.indexOf(firstCard.type);

      if (lastColumnCardIndex != firstDraggedCardIndex + 1) {
        return false;
      }
    } else {
      if (destination.last.color == CardColor.black) {
        return false;
      }

      final lastColumnCardIndex =
          CardType.values.indexOf(destination.last.type);
      final firstDraggedCardIndex = CardType.values.indexOf(firstCard.type);

      if (lastColumnCardIndex != firstDraggedCardIndex + 1) {
        return false;
      }
    }
    return true;
  }

  /// Checks if the player has won or loose
  /// Refreshes the display if game continues.
  void _refreshState() {
    if (game.finalDecks.fold<int>(0, (p, deck) => p + deck.length) == 52) {
      _handleWin();
    } else if (_isGameOver()) {
      _handleLose();
    } else {
      setState(() {});
    }
  }

  bool _isGameOver() {
    // See if open deck can be added somewhere
    if (game.cardDeckOpened.isNotEmpty) {
      final cards = [game.cardDeckOpened.last];
      for (final deck in game.finalDecks) {
        if (_willAcceptCardsOnFinalDeck(cards: cards, deck: deck)) {
          return false;
        }
      }

      for (final column in game.cardColumns) {
        if (_willAcceptCardsOnColumn(destination: column, cards: cards)) {
          return false;
        }
      }
    }

    // See if a top card in the columns can be added to the final decks
    for (final column in game.cardColumns) {
      if (column.isEmpty) continue;
      for (final deck in game.finalDecks) {
        if (_willAcceptCardsOnFinalDeck(cards: [column.last], deck: deck)) {
          return false;
        }
      }
    }

    // See if any faceUp card in the colums can be added to another column
    for (final column in game.cardColumns) {
      for (final other in game.cardColumns) {
        if (column.isEmpty || column == other) continue;

        for (final card in column) {
          if (!card.faceUp) continue;

          if (_willAcceptCardsOnColumn(destination: other, cards: [card])) {
            return false;
          }
        }
      }
    }

    return true;
  }

  // Handle a win condition
  void _handleWin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: const Text("You Win!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Play again"),
            ),
          ],
        );
      },
    );
  }

  void _handleLose() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("You lose!"),
          content: const Text("Maybe next time..."),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  game = Game.klondike();
                });
                Navigator.pop(context);
              },
              child: const Text("Play again"),
            ),
          ],
        );
      },
    );
  }
}
