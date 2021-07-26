import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/playing_card.dart';
import 'dart:ui' as ui;

Image suitToImage(CardSuit suit, {required double scale}) {
  String assetName;

  switch (suit) {
    case CardSuit.hearts:
      assetName = 'assets/cards/private/hearts.png';
      break;
    case CardSuit.diamonds:
      assetName = 'assets/cards/private/diamonds.png';
      break;
    case CardSuit.clubs:
      assetName = 'assets/cards/private/clubs.png';
      break;
    case CardSuit.spades:
      assetName = 'assets/cards/private/spades.png';
      break;
  }

  return Image.asset(assetName, scale: scale);
}

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
