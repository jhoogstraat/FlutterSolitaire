import 'dart:async';

import 'package:flutter/services.dart';

import '../models/playing_card.dart';
import 'dart:ui' as ui;

typedef WillAcceptCardCallback = bool Function({
  required List<PlayingCard> cards,
  required List<PlayingCard> destination,
});

typedef CardAcceptCallback = void Function(
  List<PlayingCard> cards,
  List<PlayingCard> source,
);

final suitCache = <CardSuit, ui.Image>{};

Future<void> cacheSuits() async {
  await Future.wait(
    [
      _loadImage('assets/cards/private/clubs.png')
          .then((value) => suitCache[CardSuit.clubs] = value),
      _loadImage('assets/cards/private/hearts.png')
          .then((value) => suitCache[CardSuit.hearts] = value),
      _loadImage('assets/cards/private/diamonds.png')
          .then((value) => suitCache[CardSuit.diamonds] = value),
      _loadImage('assets/cards/private/spades.png')
          .then((value) => suitCache[CardSuit.spades] = value),
    ],
  );
}

Future<ui.Image> _loadImage(String assetName) async {
  final data = await rootBundle.load(assetName);
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(
      data.buffer.asUint8List(), (img) => completer.complete(img));
  return completer.future;
}

String cardTypeToString(PlayingCard card) {
  switch (card.type) {
    case CardType.two:
      return "2";
    case CardType.three:
      return "3";
    case CardType.four:
      return "4";
    case CardType.five:
      return "5";
    case CardType.six:
      return "6";
    case CardType.seven:
      return "7";
    case CardType.eight:
      return "8";
    case CardType.nine:
      return "9";
    case CardType.ten:
      return "10";
    case CardType.jack:
      return "J";
    case CardType.queen:
      return "Q";
    case CardType.king:
      return "K";
    case CardType.ace:
      return "A";
  }
}
