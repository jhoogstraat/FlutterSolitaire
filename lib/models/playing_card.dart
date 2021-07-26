enum CardSuit {
  spades,
  hearts,
  diamonds,
  clubs,
}

enum CardType {
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  ace,
}

enum CardColor {
  red,
  black,
}

// Simple playing card model
class PlayingCard {
  CardSuit suit;
  CardType type;
  bool faceUp;
  bool opened;
  CardColor color;

  PlayingCard({
    required this.suit,
    required this.type,
    this.faceUp = false,
    this.opened = false,
  }) : color = cardColorForSuit(suit);

  static CardColor cardColorForSuit(CardSuit cardSuit) {
    if (cardSuit == CardSuit.hearts || cardSuit == CardSuit.diamonds) {
      return CardColor.red;
    } else {
      return CardColor.black;
    }
  }
}
