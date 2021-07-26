enum CardSuit {
  spades,
  hearts,
  diamonds,
  clubs,
}

enum CardType {
  ace,
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
  CardColor color;

  PlayingCard({
    required this.suit,
    required this.type,
    this.faceUp = false,
  }) : color = cardColorForSuit(suit);

  static CardColor cardColorForSuit(CardSuit cardSuit) {
    if (cardSuit == CardSuit.hearts || cardSuit == CardSuit.diamonds) {
      return CardColor.red;
    } else {
      return CardColor.black;
    }
  }
}
