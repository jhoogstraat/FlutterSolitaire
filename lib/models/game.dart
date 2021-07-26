import 'playing_card.dart';

class Game {
  Game({required int columns})
      : cardColumns = List.generate(columns, (index) => <PlayingCard>[]);

  // Stores the card columns
  List<List<PlayingCard>> cardColumns;

  // Stores the card deck
  List<PlayingCard> cardDeckClosed = [];
  List<PlayingCard> cardDeckOpened = [];

  // Stores the card in the upper boxes
  List<PlayingCard> finalHeartsDeck = [];
  List<PlayingCard> finalDiamondsDeck = [];
  List<PlayingCard> finalSpadesDeck = [];
  List<PlayingCard> finalClubsDeck = [];
}
