import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_nex/game/ludo_engine.dart';

void main() {
  group('Ludo Nex rules engine', () {
    test('a pawn leaves base only when the die shows six', () {
      final game = LudoGame.create(
        mode: LudoMode.local,
        playerCount: 2,
        difficulty: LudoDifficulty.normal,
      );

      game.rollDice(5);
      expect(game.legalMoves, isEmpty);
      game.passAfterNoMoves();
      expect(game.currentPlayerIndex, 1);

      game.rollDice(6);
      expect(game.legalMoves, <int>[0, 1, 2, 3]);
    });

    test('rolling a six to leave base grants an extra turn', () {
      final game = LudoGame.create(
        mode: LudoMode.local,
        playerCount: 2,
        difficulty: LudoDifficulty.normal,
      );

      game.rollDice(6);
      final move = game.movePiece(0);

      expect(move.newProgress, 0);
      expect(move.extraTurn, isTrue);
      expect(game.currentPlayerIndex, 0);
      expect(game.players[0].pieces[0], 0);
    });

    test('the exact finishing count is required', () {
      final game = LudoGame.create(
        mode: LudoMode.local,
        playerCount: 2,
        difficulty: LudoDifficulty.normal,
      );
      game.players[0].pieces[0] = 55;

      game.rollDice(3);
      expect(game.legalMoves, isEmpty);
      game.passAfterNoMoves();
      expect(game.currentPlayerIndex, 1);
    });

    test('a token is captured on a non-safe square', () {
      final game = LudoGame.create(
        mode: LudoMode.local,
        playerCount: 2,
        difficulty: LudoDifficulty.normal,
      );
      game.players[0].pieces[0] = 0;
      game.players[1].pieces[0] = 27;

      game.rollDice(1);
      final move = game.movePiece(0);

      expect(move.newProgress, 1);
      expect(move.captured, hasLength(1));
      expect(game.players[1].pieces[0], -1);
    });

    test('the 52-space route uses four colored entry gates', () {
      final start = LudoBoardGeometry.trackPoint(0);
      final right = LudoBoardGeometry.trackPoint(13);
      final bottom = LudoBoardGeometry.trackPoint(26);
      final left = LudoBoardGeometry.trackPoint(39);

      expect(start.x, closeTo(0, 0.01));
      expect(start.z, closeTo(-3, 0.01));
      expect(right.x, closeTo(3, 0.01));
      expect(right.z, closeTo(0, 0.01));
      expect(bottom.x, closeTo(0, 0.01));
      expect(bottom.z, closeTo(3, 0.01));
      expect(left.x, closeTo(-3, 0.01));
      expect(left.z, closeTo(0, 0.01));
    });
  });
}
