import 'dart:math';

import 'package:flutter/material.dart';

import 'game/board_3d_view.dart';
import 'game/ludo_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LudoNexApp());
}

class Nex {
  static const bg = Color(0xFF061326);
  static const panel = Color(0xFF0B1D35);
  static const panel2 = Color(0xFF102844);
  static const panel3 = Color(0xFF183B5F);
  static const gold = Color(0xFFF0C66E);
  static const goldLight = Color(0xFFFFE5AD);
  static const text = Color(0xFFF5F7FD);
  static const muted = Color(0xFF9CB2CD);
  static const stroke = Color(0xFF294967);
}

class LudoNexApp extends StatelessWidget {
  const LudoNexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Nex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Nex.bg,
        colorScheme: const ColorScheme.dark(
          primary: Nex.gold,
          secondary: Color(0xFF3BCBF3),
          surface: Nex.panel,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Ludo3DScene(
            players: <LudoPlayer>[],
            preview: true,
            pixelRatio: 0.82,
            maxFrameRate: 38,
            orbitEnabled: true,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xF5061326),
                  Color(0x40061326),
                  Color(0x33061326),
                  Color(0xF0061326),
                  Color(0xFF061326),
                ],
                stops: [0, 0.16, 0.43, 0.76, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 15, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Brand(),
                  SizedBox(height: screenHeight * 0.30),
                  const Text(
                    'O TABULEIRO\nGANHOU OUTRA DIMENSÃO.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Nex.text,
                      fontSize: 27,
                      height: 1.06,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ludo clássico. Peças tridimensionais.\nCada jogada ganha vida.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Nex.muted,
                      fontSize: 13,
                      height: 1.45,
                      letterSpacing: 0.25,
                    ),
                  ),
                  const Spacer(),
                  _GoldButton(
                    label: 'COMEÇAR PARTIDA',
                    icon: Icons.play_arrow_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SetupScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineButton(
                          label: 'REGRAS',
                          icon: Icons.menu_book_rounded,
                          onTap: () => _showRules(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _OutlineButton(
                          label: 'SOBRE',
                          icon: Icons.auto_awesome_rounded,
                          onTap: () => showAboutDialog(
                            context: context,
                            applicationName: 'Ludo Nex',
                            applicationVersion: '0.2.0',
                            applicationLegalese: 'Um jogo original Nexauren.',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  const Text(
                    'OFFLINE  •  2–4 JOGADORES  •  3D',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Nex.muted,
                      fontSize: 9,
                      letterSpacing: 1.7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const _NexDialog(
        title: 'REGRAS CLÁSSICAS',
        body: 'Lança um seis para retirar uma peça da base. Percorre o circuito, '
            'usa as casas seguras, captura peças adversárias e chega ao centro '
            'com o número exato. Cada jogador tem quatro peças. Vence quem '
            'levar todas as peças para casa.',
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Nex.goldLight, Nex.gold, Color(0xFFD99F4A)],
            ),
            boxShadow: [
              BoxShadow(
                color: Nex.gold.withValues(alpha: 0.22),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.diamond_rounded,
            color: Color(0xFF13243A),
            size: 25,
          ),
        ),
        const SizedBox(width: 11),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEXAUREN  /  GAME STUDIO',
              style: TextStyle(
                color: Nex.muted,
                fontSize: 9,
                letterSpacing: 1.45,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'LUDO NEX',
              style: TextStyle(
                color: Nex.text,
                fontSize: 21,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: Nex.panel.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Nex.stroke),
          ),
          child: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Nex.gold, size: 13),
              SizedBox(width: 6),
              Text(
                'OFFLINE',
                style: TextStyle(
                  color: Nex.muted,
                  fontSize: 9,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  LudoMode _mode = LudoMode.computer;
  LudoDifficulty _difficulty = LudoDifficulty.normal;
  int _playerCount = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Nex.bg,
        title: const Text(
          'CONFIGURAR PARTIDA',
          style: TextStyle(
            color: Nex.text,
            fontSize: 12,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _SectionTitle('ESCOLHE O TEU MODO'),
            const SizedBox(height: 12),
            _ModeCard(
              selected: _mode == LudoMode.computer,
              icon: Icons.smart_toy_rounded,
              title: 'CONTRA O COMPUTADOR',
              subtitle: 'Joga offline contra adversários controlados pelo jogo.',
              onTap: () => setState(() => _mode = LudoMode.computer),
            ),
            const SizedBox(height: 10),
            _ModeCard(
              selected: _mode == LudoMode.local,
              icon: Icons.people_alt_rounded,
              title: 'MULTIJOGADOR LOCAL',
              subtitle: 'Passa o dispositivo aos restantes jogadores.',
              onTap: () => setState(() => _mode = LudoMode.local),
            ),
            const SizedBox(height: 26),
            const _SectionTitle('NÚMERO DE JOGADORES'),
            const SizedBox(height: 12),
            Row(
              children: [2, 3, 4].map((count) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: count == 4 ? 0 : 9),
                    child: _Choice(
                      title: count.toString(),
                      selected: _playerCount == count,
                      onTap: () => setState(() => _playerCount = count),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_mode == LudoMode.computer) ...[
              const SizedBox(height: 25),
              const _SectionTitle('DIFICULDADE DO COMPUTADOR'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _difficultyChoice('FÁCIL', LudoDifficulty.easy),
                  const SizedBox(width: 8),
                  _difficultyChoice('NORMAL', LudoDifficulty.normal),
                  const SizedBox(width: 8),
                  _difficultyChoice('DIFÍCIL', LudoDifficulty.hard),
                ],
              ),
            ],
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Nex.panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Nex.stroke),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_moon_rounded, color: Nex.gold, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sem conta, sem anúncios e sem ligação à internet nesta primeira versão.',
                      style: TextStyle(
                        color: Nex.muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _GoldButton(
              label: 'ABRIR TABULEIRO 3D',
              icon: Icons.view_in_ar_rounded,
              onTap: () {
                final game = LudoGame.create(
                  mode: _mode,
                  playerCount: _playerCount,
                  difficulty: _difficulty,
                );
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GameScreen(game: game),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _difficultyChoice(String label, LudoDifficulty value) {
    return Expanded(
      child: _Choice(
        title: label,
        selected: _difficulty == value,
        onTap: () => setState(() => _difficulty = value),
        compact: true,
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.game});
  final LudoGame game;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _sceneKey = GlobalKey<Ludo3DSceneState>();
  final _random = Random();
  bool _busy = false;
  bool _cpuRunning = false;
  String? _message;

  LudoGame get game => widget.game;

  Future<void> _humanRoll() async {
    if (_busy || game.isComplete || game.diceValue != null) return;
    if (game.currentPlayer.isComputer) return;
    await _rollAndResolve(computer: false);
  }

  Future<void> _rollAndResolve({required bool computer}) async {
    if (_busy || game.isComplete || game.diceValue != null) return;
    setState(() {
      _busy = true;
      _message = 'A lançar o dado...';
    });

    final value = _random.nextInt(6) + 1;
    game.rollDice(value);
    await _sceneKey.currentState?.animateDice(value);
    if (!mounted) return;

    setState(() {
      _busy = false;
      _message = game.legalMoves.isEmpty
          ? 'Nenhuma peça pode mover-se.'
          : 'O dado mostrou ' + value.toString() + '. Escolhe uma peça.';
    });

    if (game.legalMoves.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 750));
      game.passAfterNoMoves();
      if (!mounted) return;
      setState(() => _message = null);
      if (computer) return;
      _startComputerIfNeeded();
    } else if (computer) {
      await Future<void>.delayed(const Duration(milliseconds: 520));
      final piece = game.chooseComputerMove(_random);
      if (piece >= 0) await _movePiece(piece, computer: true);
    }
  }

  Future<void> _movePiece(int pieceIndex, {bool computer = false}) async {
    if (_busy || !game.legalMoves.contains(pieceIndex)) return;
    if (!computer && game.currentPlayer.isComputer) return;

    final result = game.movePiece(pieceIndex);
    setState(() {
      _busy = false;
      _message = result.won
          ? game.players[result.playerIndex].name + ' venceu!'
          : result.captured.isNotEmpty
              ? 'Captura! Uma peça adversária regressou à base.'
              : result.extraTurn
                  ? 'Saiu um seis. Tens mais uma jogada.'
                  : null;
    });

    // The 3D scene receives the changed progress and animates the matching GLB node.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    if (result.won) {
      _showWinner();
    } else {
      _startComputerIfNeeded();
    }
  }

  void _startComputerIfNeeded() {
    if (!mounted ||
        _cpuRunning ||
        game.isComplete ||
        !game.currentPlayer.isComputer) {
      return;
    }
    _runComputerTurns();
  }

  Future<void> _runComputerTurns() async {
    _cpuRunning = true;
    try {
      while (mounted && !game.isComplete && game.currentPlayer.isComputer) {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        await _rollAndResolve(computer: true);
        if (!mounted || game.isComplete) break;
        if (game.currentPlayer.isComputer && game.diceValue != null) {
          // The CPU's move is handled by _rollAndResolve.
          continue;
        }
      }
    } finally {
      _cpuRunning = false;
    }
  }

  void _showWinner() {
    final winner = game.players[game.winnerIndex!];
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Nex.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Nex.stroke),
        ),
        title: const Text(
          'VITÓRIA!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Nex.gold,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 65, color: Nex.gold),
            const SizedBox(height: 12),
            Text(
              winner.name,
              style: const TextStyle(
                color: Nex.text,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'As quatro peças chegaram ao centro.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Nex.muted),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('VOLTAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = game.currentPlayer;
    final style = LudoPlayerStyle.all[player.colorId];
    return Scaffold(
      backgroundColor: Nex.bg,
      body: SafeArea(
        child: Column(
          children: [
            _GameHeader(
              turn: game.turnCount,
              onBack: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 7),
              child: _PlayerBar(
                players: game.players,
                activePlayer: player,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Ludo3DScene(
                  key: _sceneKey,
                  players: game.players,
                  pixelRatio: 0.90,
                  maxFrameRate: 50,
                ),
              ),
            ),
            _GameDock(
              player: player,
              style: style,
              diceValue: game.diceValue,
              legalMoves: game.legalMoves,
              busy: _busy,
              message: _message,
              onRoll: _humanRoll,
              onMove: _movePiece,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({required this.turn, required this.onBack});
  final int turn;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 5, 14, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: Nex.panel,
              side: const BorderSide(color: Nex.stroke),
            ),
            icon: const Icon(Icons.arrow_back_rounded, color: Nex.gold),
          ),
          const SizedBox(width: 7),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LUDO NEX',
                  style: TextStyle(
                    color: Nex.text,
                    fontSize: 15,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'PARTIDA CLÁSSICA  /  3D',
                  style: TextStyle(
                    color: Nex.muted,
                    fontSize: 9,
                    letterSpacing: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Nex.panel,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Nex.stroke),
            ),
            child: Text(
              'TURNO ' + turn.toString(),
              style: const TextStyle(
                color: Nex.gold,
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerBar extends StatelessWidget {
  const _PlayerBar({
    required this.players,
    required this.activePlayer,
  });

  final List<LudoPlayer> players;
  final LudoPlayer activePlayer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: players.map((player) {
        final style = LudoPlayerStyle.all[player.colorId];
        final active = player.seat == activePlayer.seat;
        final color = Color(style.color);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              decoration: BoxDecoration(
                color: active ? color.withValues(alpha: 0.16) : Nex.panel,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: active ? color : Nex.stroke,
                  width: active ? 1.45 : 0.8,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.65),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active ? Nex.text : Nex.muted,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player.finishedCount.toString() + '/4',
                    style: TextStyle(
                      color: active ? color : Nex.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GameDock extends StatelessWidget {
  const _GameDock({
    required this.player,
    required this.style,
    required this.diceValue,
    required this.legalMoves,
    required this.busy,
    required this.message,
    required this.onRoll,
    required this.onMove,
  });

  final LudoPlayer player;
  final LudoPlayerStyle style;
  final int? diceValue;
  final List<int> legalMoves;
  final bool busy;
  final String? message;
  final Future<void> Function() onRoll;
  final Future<void> Function(int) onMove;

  @override
  Widget build(BuildContext context) {
    final color = Color(style.color);
    return Container(
      margin: const EdgeInsets.fromLTRB(11, 4, 11, 11),
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
      decoration: BoxDecoration(
        color: Nex.panel.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Nex.stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.65), blurRadius: 8),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  busy
                      ? 'A PROCESSAR JOGADA'
                      : diceValue == null
                          ? 'VEZ DE ' + player.name
                          : 'ESCOLHE UMA PEÇA',
                  style: const TextStyle(
                    color: Nex.text,
                    letterSpacing: 1.0,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (diceValue != null)
                Text(
                  'DADO: ' + diceValue.toString(),
                  style: const TextStyle(
                    color: Nex.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          if (message != null) ...[
            const SizedBox(height: 7),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Nex.muted,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ],
          const SizedBox(height: 11),
          if (diceValue == null)
            _GoldButton(
              label: busy ? 'A LANÇAR...' : 'LANÇAR DADO',
              icon: Icons.casino_rounded,
              compact: true,
              onTap: busy || player.isComputer ? null : () => onRoll(),
            )
          else if (legalMoves.isEmpty)
            const Text(
              'A preparar o próximo turno...',
              style: TextStyle(color: Nex.muted, fontSize: 11),
            )
          else
            Row(
              children: legalMoves.map((piece) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: piece == legalMoves.last ? 0 : 7,
                    ),
                    child: _Choice(
                      title: 'PEÇA ' + (piece + 1).toString(),
                      selected: false,
                      accent: color,
                      compact: true,
                      onTap: busy || player.isComputer
                          ? null
                          : () => onMove(piece),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Nex.gold,
        fontSize: 11,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? Nex.panel3 : Nex.panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Nex.gold : Nex.stroke,
            width: selected ? 1.45 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: selected ? Nex.gold.withValues(alpha: 0.14) : Nex.panel2,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: Nex.gold, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Nex.text,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Nex.muted,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? Nex.gold : Nex.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.title,
    required this.selected,
    required this.onTap,
    this.compact = false,
    this.accent,
  });

  final String title;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Nex.gold;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: compact ? 43 : 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : Nex.panel,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? color : Nex.stroke,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? color : Nex.text,
            fontWeight: FontWeight.w900,
            fontSize: compact ? 9 : 16,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 14.0 : 18.0;
    return SizedBox(
      width: double.infinity,
      height: compact ? 50 : 61,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Nex.goldLight, Nex.gold, Color(0xFFD39A42)],
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Nex.gold.withValues(alpha: onTap == null ? 0.04 : 0.22),
              blurRadius: compact ? 12 : 21,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF10213A),
            disabledForegroundColor: const Color(0xFF65758A),
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: compact ? 18 : 22),
              const SizedBox(width: 9),
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 12 : 14,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Nex.text,
          backgroundColor: Nex.panel.withValues(alpha: 0.72),
          side: const BorderSide(color: Nex.stroke),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 10,
            letterSpacing: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _NexDialog extends StatelessWidget {
  const _NexDialog({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Nex.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Nex.stroke),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Nex.gold,
          fontSize: 14,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Text(
        body,
        style: const TextStyle(
          color: Nex.muted,
          fontSize: 13,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('FECHAR'),
        ),
      ],
    );
  }
}
