import 'dart:math';

import 'package:flutter/foundation.dart';

enum LudoMode { computer, local }
enum LudoDifficulty { easy, normal, hard }

@immutable
class LudoPlayerStyle {
  const LudoPlayerStyle({
    required this.id,
    required this.name,
    required this.color,
    required this.glb,
  });

  final int id;
  final String name;
  final int color;
  final String glb;

  static const all = <LudoPlayerStyle>[
    LudoPlayerStyle(
      id: 0,
      name: 'RUBI',
      color: 0xFFFF536A,
      glb: 'assets/models/token_ruby.glb',
    ),
    LudoPlayerStyle(
      id: 1,
      name: 'AZUL',
      color: 0xFF23C6F4,
      glb: 'assets/models/token_cyan.glb',
    ),
    LudoPlayerStyle(
      id: 2,
      name: 'ESMERALDA',
      color: 0xFF35D995,
      glb: 'assets/models/token_emerald.glb',
    ),
    LudoPlayerStyle(
      id: 3,
      name: 'SOLAR',
      color: 0xFFFFC957,
      glb: 'assets/models/token_solar.glb',
    ),
  ];
}

class LudoPlayer {
  LudoPlayer({
    required this.seat,
    required this.colorId,
    required this.name,
    required this.isComputer,
  });

  final int seat;
  final int colorId;
  final String name;
  final bool isComputer;
  final List<int> pieces = <int>[-1, -1, -1, -1];

  int get finishedCount => pieces.where((value) => value == 57).length;
  bool get hasWon => finishedCount == 4;
}

@immutable
class CapturedToken {
  const CapturedToken({
    required this.playerIndex,
    required this.pieceIndex,
  });

  final int playerIndex;
  final int pieceIndex;
}

@immutable
class LudoMove {
  const LudoMove({
    required this.playerIndex,
    required this.pieceIndex,
    required this.oldProgress,
    required this.newProgress,
    required this.captured,
    required this.won,
    required this.extraTurn,
  });

  final int playerIndex;
  final int pieceIndex;
  final int oldProgress;
  final int newProgress;
  final List<CapturedToken> captured;
  final bool won;
  final bool extraTurn;
}

class LudoGame {
  LudoGame._({
    required this.mode,
    required this.difficulty,
    required this.players,
  });

  static const safeSquares = <int>[0, 8, 13, 21, 26, 34, 39, 47];

  final LudoMode mode;
  final LudoDifficulty difficulty;
  final List<LudoPlayer> players;

  int currentPlayerIndex = 0;
  int? diceValue;
  int? winnerIndex;
  int turnCount = 1;

  LudoPlayer get currentPlayer => players[currentPlayerIndex];
  bool get isComplete => winnerIndex != null;

  List<int> get legalMoves {
    final roll = diceValue;
    if (roll == null || isComplete) return const <int>[];
    final options = <int>[];
    for (var i = 0; i < currentPlayer.pieces.length; i++) {
      final progress = currentPlayer.pieces[i];
      if (progress == -1 && roll == 6) options.add(i);
      if (progress >= 0 && progress < 57 && progress + roll <= 57) {
        options.add(i);
      }
    }
    return options;
  }

  factory LudoGame.create({
    required LudoMode mode,
    required int playerCount,
    required LudoDifficulty difficulty,
    String firstPlayerName = 'JOGADOR',
  }) {
    final colors = switch (playerCount) {
      2 => <int>[0, 2],
      3 => <int>[0, 1, 2],
      _ => <int>[0, 1, 2, 3],
    };
    final players = <LudoPlayer>[];
    for (var index = 0; index < colors.length; index++) {
      final isComputer = mode == LudoMode.computer && index > 0;
      players.add(
        LudoPlayer(
          seat: index,
          colorId: colors[index],
          name: index == 0
              ? firstPlayerName
              : isComputer
                  ? 'CPU ' + index.toString()
                  : 'JOGADOR ' + (index + 1).toString(),
          isComputer: isComputer,
        ),
      );
    }
    return LudoGame._(
      mode: mode,
      difficulty: difficulty,
      players: players,
    );
  }

  void rollDice(int value) {
    if (diceValue != null || isComplete) return;
    diceValue = value.clamp(1, 6);
  }

  LudoMove movePiece(int pieceIndex) {
    if (!legalMoves.contains(pieceIndex) || diceValue == null) {
      throw StateError('Movimento não permitido.');
    }

    final playerIndex = currentPlayerIndex;
    final player = currentPlayer;
    final roll = diceValue!;
    final oldProgress = player.pieces[pieceIndex];
    final newProgress = oldProgress == -1 ? 0 : oldProgress + roll;
    player.pieces[pieceIndex] = newProgress;

    final captured = <CapturedToken>[];
    if (newProgress >= 0 && newProgress < 52) {
      final target = globalTrackIndex(player.colorId, newProgress);
      if (!safeSquares.contains(target)) {
        for (var opponentIndex = 0;
            opponentIndex < players.length;
            opponentIndex++) {
          if (opponentIndex == playerIndex) continue;
          final opponent = players[opponentIndex];
          for (var piece = 0; piece < opponent.pieces.length; piece++) {
            final progress = opponent.pieces[piece];
            if (progress < 0 || progress >= 52) continue;
            if (globalTrackIndex(opponent.colorId, progress) == target) {
              opponent.pieces[piece] = -1;
              captured.add(
                CapturedToken(
                  playerIndex: opponentIndex,
                  pieceIndex: piece,
                ),
              );
            }
          }
        }
      }
    }

    final won = player.hasWon;
    if (won) winnerIndex = playerIndex;
    diceValue = null;
    final extraTurn = roll == 6 && !won;
    if (!won && !extraTurn) advanceTurn();

    return LudoMove(
      playerIndex: playerIndex,
      pieceIndex: pieceIndex,
      oldProgress: oldProgress,
      newProgress: newProgress,
      captured: captured,
      won: won,
      extraTurn: extraTurn,
    );
  }

  void passAfterNoMoves() {
    final roll = diceValue;
    if (roll == null) return;
    diceValue = null;
    if (roll != 6) advanceTurn();
  }

  void advanceTurn() {
    if (isComplete || players.isEmpty) return;
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    turnCount++;
    diceValue = null;
  }

  int chooseComputerMove([Random? random]) {
    final options = legalMoves;
    if (options.isEmpty) return -1;
    final rng = random ?? Random();
    if (difficulty == LudoDifficulty.easy) {
      return options[rng.nextInt(options.length)];
    }

    var bestIndex = options.first;
    var bestScore = -double.infinity;
    final player = currentPlayer;
    for (final pieceIndex in options) {
      final previous = player.pieces[pieceIndex];
      final next = previous == -1 ? 0 : previous + diceValue!;
      var score = next * 2.0;
      if (previous == -1) score += 40;
      if (next == 57) score += 1000;

      if (next >= 0 && next < 52) {
        final destination = globalTrackIndex(player.colorId, next);
        if (safeSquares.contains(destination)) score += 30;
        for (var opponentIndex = 0;
            opponentIndex < players.length;
            opponentIndex++) {
          if (opponentIndex == currentPlayerIndex) continue;
          final opponent = players[opponentIndex];
          for (final opponentProgress in opponent.pieces) {
            if (opponentProgress < 0 || opponentProgress >= 52) continue;
            final opponentSquare =
                globalTrackIndex(opponent.colorId, opponentProgress);
            if (opponentSquare == destination) score += 180;
            if (difficulty == LudoDifficulty.hard &&
                !safeSquares.contains(destination)) {
              final distance = (destination - opponentSquare + 52) % 52;
              if (distance > 0 && distance <= 6) score -= 20;
            }
          }
        }
      }
      score += rng.nextDouble() * 0.2;
      if (score > bestScore) {
        bestScore = score;
        bestIndex = pieceIndex;
      }
    }
    return bestIndex;
  }

  static int globalTrackIndex(int colorId, int progress) {
    return (colorId * 13 + progress) % 52;
  }
}

@immutable
class BoardPoint {
  const BoardPoint(this.x, this.z);
  final double x;
  final double z;
}

@immutable
class TokenPosition {
  const TokenPosition(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}

class LudoBoardGeometry {
  static const baseCenters = <BoardPoint>[
    BoardPoint(-4.7, -4.7),
    BoardPoint(4.7, -4.7),
    BoardPoint(4.7, 4.7),
    BoardPoint(-4.7, 4.7),
  ];

  static const slots = <BoardPoint>[
    BoardPoint(-0.78, -0.78),
    BoardPoint(0.78, -0.78),
    BoardPoint(-0.78, 0.78),
    BoardPoint(0.78, 0.78),
  ];

  static BoardPoint trackPoint(int index) {
    final distance = (index % 52) * (24.0 / 52.0);
    if (distance < 3) return BoardPoint(distance, -3);
    if (distance < 9) return BoardPoint(3, -3 + distance - 3);
    if (distance < 15) return BoardPoint(3 - (distance - 9), 3);
    if (distance < 21) return BoardPoint(-3, 3 - (distance - 15));
    return BoardPoint(-3 + (distance - 21), -3);
  }

  static TokenPosition positionFor({
    required int colorId,
    required int pieceIndex,
    required int progress,
  }) {
    if (progress == -1) {
      final center = baseCenters[colorId];
      final slot = slots[pieceIndex];
      return TokenPosition(center.x + slot.x, 1.13, center.z + slot.z);
    }
    if (progress < 52) {
      final point = trackPoint(LudoGame.globalTrackIndex(colorId, progress));
      return TokenPosition(point.x, 0.62, point.z);
    }
    if (progress < 57) {
      final step = progress - 52;
      final along = 2.5 - step * 0.5;
      final point = switch (colorId) {
        0 => BoardPoint(0, -along),
        1 => BoardPoint(along, 0),
        2 => BoardPoint(0, along),
        _ => BoardPoint(-along, 0),
      };
      return TokenPosition(point.x, 0.67, point.z);
    }
    final slot = slots[pieceIndex];
    return TokenPosition(slot.x * 0.28, 0.95, slot.z * 0.28);
  }
}
