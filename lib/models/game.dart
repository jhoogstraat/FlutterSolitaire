import 'dart:math';

import 'playing_card.dart';

class Game {
  const Game({
    required this.cardColumns,
    required this.cardDeckClosed,
    required this.finalDecks,
    required this.cardDeckOpened,
  });

  /// 7 card columns
  factory Game.klondike() {
    final allCards = <PlayingCard>[];

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

    // Get random cards
    final random = Random();

    // Add cards to columns and remaining to deck
    final cardColumns = List.generate(7, (index) => <PlayingCard>[]);
    for (int j = 7; j > 0; j--) {
      for (int i = 7 - j; i < 7; i++) {
        final card = allCards.removeAt(random.nextInt(allCards.length));
        cardColumns[i].add(card);
      }
    }

    // Flip last card in each column up
    for (final column in cardColumns) {
      column.last.faceUp = true;
    }

    // Shuffle remaining cards
    allCards.shuffle(random);

    // Add remaining cards to the closed deck.
    final cardDeckClosed = allCards;

    return Game(
        cardColumns: cardColumns,
        cardDeckClosed: cardDeckClosed,
        cardDeckOpened: [],
        finalDecks: [[], [], [], []]);
  }

  // Stores the card columns
  final List<List<PlayingCard>> cardColumns;

  // Stores the card deck
  final List<PlayingCard> cardDeckClosed;
  final List<PlayingCard> cardDeckOpened;

  // Stores the card in the upper boxes
  final List<List<PlayingCard>> finalDecks;
}
