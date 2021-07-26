import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solitaire_flutter/app/widgets/card_column.dart';
import 'package:solitaire_flutter/app/widgets/empty_card_deck.dart';
import 'package:solitaire_flutter/models/game.dart';
import 'package:solitaire_flutter/models/playing_card.dart';
import 'package:solitaire_flutter/app/widgets/pickable_card.dart';

class CardSizeProvider extends InheritedWidget {
  const CardSizeProvider({Key? key, required Widget child, required this.size})
      : super(key: key, child: child);

  final Size size;

  static CardSizeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CardSizeProvider>()!;
  }

  static double? width(BuildContext context) {
    return of(context).size.width;
  }

  static double? height(BuildContext context) {
    return of(context).size.height;
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
    _initialiseGame();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/backgrounds/table_cloth.jpg"),
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
                onPressed: _initialiseGame, icon: const Icon(Icons.refresh))
          ],
        ),
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) => CardSizeProvider(
            size: Size(2 * 56, 2 * 89),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCardDeck(),
                    _buildFinalDecks(),
                  ],
                ),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: game.cardColumns.map(
                    (column) {
                      return CardColumn(
                        cards: column,
                        onCardsAdded: (cards, index) {
                          setState(() {
                            column.addAll(cards);
                            // int length = _getListFromIndex(index)!.length;
                            // _getListFromIndex(index)!
                            //     .removeRange(length - cards.length, length);
                            _refreshList(index);
                          });
                        },
                        columnIndex: 1,
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the deck of cards left after building card columns
  Widget _buildCardDeck() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (game.cardDeckClosed.isEmpty) {
                game.cardDeckClosed.addAll(game.cardDeckOpened.map((card) {
                  return card
                    ..opened = false
                    ..faceUp = false;
                }));
                game.cardDeckOpened.clear();
              } else {
                game.cardDeckOpened.add(
                  game.cardDeckClosed.removeLast()
                    ..faceUp = true
                    ..opened = true,
                );
              }
            });
          },
          child: game.cardDeckClosed.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: PickableCard(
                    playingCard: game.cardDeckClosed.last,
                  ),
                )
              : Opacity(
                  opacity: 0.4,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: PickableCard(
                      playingCard: PlayingCard(
                        suit: CardSuit.diamonds,
                        type: CardType.five,
                      ),
                    ),
                  ),
                ),
        ),
        game.cardDeckOpened.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: PickableCard(
                  playingCard: game.cardDeckOpened.last,
                  attachedCards: [
                    game.cardDeckOpened.last,
                  ],
                  columnIndex: 0,
                ),
              )
            : Container(width: 40.0),
      ],
    );
  }

  // Build the final decks of cards
  Widget _buildFinalDecks() {
    return Row(
      children: CardSuit.values.map(
        (suit) {
          return EmptyCardDeck(
            cardSuit: suit,
            cardsAdded: game.finalHeartsDeck,
            onCardAdded: (cards, index) {
              game.finalHeartsDeck.addAll(cards);
              // int length = _getListFromIndex(index)!.length;
              // _getListFromIndex(index)!
              //     .removeRange(length - cards.length, length);
              _refreshList(index);
            },
          );
        },
      ).toList(),
    );
  }

  // Initialise a new game
  void _initialiseGame() {
    game = Game(columns: 7);

    List<PlayingCard> allCards = [];

    // Add all cards to deck
    for (final suit in CardSuit.values) {
      for (final type in CardType.values) {
        allCards.add(PlayingCard(
          type: type,
          suit: suit,
          faceUp: false,
        ));
      }
    }

    Random random = Random();

    // Shuffle cards
    allCards.shuffle(random);

    // Add cards to columns and remaining to deck
    final nColumns = game.cardColumns.length;
    for (int i = 0; i < 28; i++) {
      final card = allCards[i];

      game.cardColumns[i % nColumns].add(
        card
          ..opened = true
          ..faceUp = true,
      );

      allCards.remove(card);
    }

    // Add remaining cards to the closed deck.
    game.cardDeckClosed = allCards;

    // Pull last card out and open it.
    game.cardDeckOpened.add(
      game.cardDeckClosed.removeLast()
        ..opened = true
        ..faceUp = true,
    );

    setState(() {});
  }

  void _refreshList(int index) {
    if (game.finalDiamondsDeck.length +
            game.finalHeartsDeck.length +
            game.finalClubsDeck.length +
            game.finalSpadesDeck.length ==
        52) {
      _handleWin();
    }

    setState(() {
      // if (_getListFromIndex(index)!.length != 0) {
      //   _getListFromIndex(index)![_getListFromIndex(index)!.length - 1]
      //     ..opened = true
      //     ..faceUp = true;
      // }
    });
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
                _initialiseGame();
                Navigator.pop(context);
              },
              child: const Text("Play again"),
            ),
          ],
        );
      },
    );
  }

  // List<PlayingCard>? _getListFromIndex(int index) {
  //   switch (index) {
  //     case 0:
  //       return cardDeckOpened;
  //     case 1:
  //       return cardColumn1;
  //     case 2:
  //       return cardColumn2;
  //     case 3:
  //       return cardColumn3;
  //     case 4:
  //       return cardColumn4;
  //     case 5:
  //       return cardColumn5;
  //     case 6:
  //       return cardColumn6;
  //     case 7:
  //       return cardColumn7;
  //     case 8:
  //       return finalHeartsDeck;
  //     case 9:
  //       return finalDiamondsDeck;
  //     case 10:
  //       return finalSpadesDeck;
  //     case 11:
  //       return finalClubsDeck;
  //     default:
  //       return null;
  //   }
  // }
}
