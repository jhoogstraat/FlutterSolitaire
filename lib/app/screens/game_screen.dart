import 'dart:math';

import 'package:flutter/material.dart';
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
  }) : super(key: key, child: child);

  final double width;
  final double height;

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
            final width =
                min(constraints.maxWidth, constraints.maxHeight) / 7 - 5;
            final height = width * 1.56;
            return CardSizeProvider(
              width: width,
              height: height,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Closed Deck
                      GestureDetector(
                        child: CardDeck(
                          cards: game.cardDeckClosed,
                          isDragTarget: false,
                          isDraggable: false,
                        ),
                        onTap: _openCardFromDeck,
                      ),

                      // Open Deck
                      CardDeck(cards: game.cardDeckOpened, isDragTarget: false),

                      // Spacer
                      SizedBox(width: width, height: height),

                      // Final decks
                      for (final deck in game.finalDecks)
                        DragTarget<Map>(
                          builder: (context, listOne, listTwo) {
                            return CardDeck(cards: deck);
                          },
                          onWillAccept: (value) {
                            // If deck is empty, allow ace.
                            // If more than one card dropped, abort
                            // Else card suit has to match last card suit and
                            // type has to be the type after the last card type
                            if (value == null || value["cards"].length > 1) {
                              return false;
                            }

                            final PlayingCard cardAdded = value["cards"].last;
                            return deck.isEmpty
                                ? cardAdded.type == CardType.ace
                                : cardAdded.suit == deck.last.suit &&
                                    CardType.values.indexOf(cardAdded.type) ==
                                        deck.length;
                          },
                          onAccept: (value) {
                            final List<PlayingCard> cards = value["cards"];
                            final List<PlayingCard> source = value["source"];
                            deck.addAll(cards);
                            cards.forEach(source.remove);
                            // Turn new last card in column
                            if (source.isNotEmpty) {
                              source.last.faceUp = true;
                            }
                            _refreshState();
                          },
                        )
                    ],
                  ),

                  // Spacer
                  const SizedBox(height: 30.0),

                  // Card Columns
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: game.cardColumns.map(
                      (column) {
                        return CardColumn(
                          cards: column,
                          onCardsAdded: (cards, source) {
                            column.addAll(cards);
                            cards.forEach(source.remove);
                            // Turn new last card in column
                            if (source.isNotEmpty) {
                              source.last.faceUp = true;
                            }
                            _refreshState();
                          },
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCardFromDeck() {
    setState(() {
      if (game.cardDeckClosed.isEmpty) {
        game.cardDeckClosed.addAll(game.cardDeckOpened);
        for (final card in game.cardDeckClosed) {
          card.faceUp = false;
        }
        game.cardDeckOpened.clear();
      } else {
        game.cardDeckOpened
            .add(game.cardDeckClosed.removeLast()..faceUp = true);
      }
    });
  }

  void _refreshState() {
    print("----------------------------------");
    print("Final Decks: ${game.finalDecks.map((e) => e.length)}");
    print("Colums: ${game.cardColumns.map((e) => e.length)}");
    print("Deck closed: ${game.cardDeckClosed.length}");
    print("Deck opened: ${game.cardDeckOpened.length}");

    if (game.finalDecks.fold<int>(0, (p, deck) => p + deck.length) == 52) {
      _handleWin();
    } else {
      setState(() {});
    }
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
                game = Game.klondike();
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
