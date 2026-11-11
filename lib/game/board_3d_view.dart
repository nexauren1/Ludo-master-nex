import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import 'ludo_engine.dart';

class Ludo3DScene extends StatefulWidget {
  const Ludo3DScene({
    super.key,
    required this.players,
    this.preview = false,
    this.pixelRatio = 0.88,
    this.maxFrameRate = 45,
    this.orbitEnabled = true,
  });

  final List<LudoPlayer> players;
  final bool preview;
  final double pixelRatio;
  final double maxFrameRate;
  final bool orbitEnabled;

  @override
  State<Ludo3DScene> createState() => Ludo3DSceneState();
}

class Ludo3DSceneState extends State<Ludo3DScene>
    with TickerProviderStateMixin {
  Scene? _scene;
  Node? _dice;
  final List<List<Node>> _tokens = List<List<Node>>.generate(
    4,
    (_) => <Node>[],
  );
  final Map<String, int> _lastProgress = <String, int>{};
  bool _loading = true;
  String? _error;
  double _yaw = 0;
  double _zoom = 1;
  double _pinchStart = 1;

  @override
  void initState() {
    super.initState();
    _loadWorld();
  }

  @override
  void didUpdateWidget(covariant Ludo3DScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_scene != null) _syncTokens(animate: true);
  }

  Future<void> _loadWorld() async {
    Scene? scene;
    try {
      await Scene.initializeStaticResources();
      scene = Scene()
        ..exposure = 1.12
        ..directionalLight = DirectionalLight(
          direction: vm.Vector3(-0.62, -1.0, -0.48),
          color: vm.Vector3(1.0, 0.82, 0.63),
          intensity: 3.2,
          castsShadow: true,
          shadowMapResolution: 1024,
          shadowCascadeCount: 3,
          shadowMaxDistance: 42,
          shadowSoftness: 0.12,
          shadowAmbientStrength: 0.32,
        );

      final board = await loadScene('assets/models/nex_board.glb');
      board
        ..name = 'Ludo Nex — master board'
        ..shadowStatic = true;
      scene.add(board);

      const tokenFiles = <String>[
        'assets/models/token_ruby.glb',
        'assets/models/token_cyan.glb',
        'assets/models/token_emerald.glb',
        'assets/models/token_solar.glb',
      ];

      for (var colorId = 0; colorId < tokenFiles.length; colorId++) {
        final source = await loadScene(tokenFiles[colorId]);
        for (var pieceIndex = 0; pieceIndex < 4; pieceIndex++) {
          final token = source.clone(recursive: true)
            ..name = 'Player_' + (colorId + 1).toString() +
                '_Piece_' + (pieceIndex + 1).toString();
          scene.add(token);
          _tokens[colorId].add(token);
        }
      }

      final dice = await loadScene('assets/models/dice.glb');
      dice
        ..name = 'Nex six-sided dice'
        ..position = vm.Vector3(0, 1.18, 8.65);
      scene.add(dice);

      if (!mounted) {
        scene.dispose();
        return;
      }
      setState(() {
        _scene = scene;
        _dice = dice;
        _loading = false;
      });
      _syncTokens(animate: false);
    } catch (error, stack) {
      debugPrint('Ludo Nex scene loading error: $error\n$stack');
      scene?.dispose();
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
      }
    }
  }

  void _syncTokens({required bool animate}) {
    if (_scene == null) return;
    final players = <int, LudoPlayer>{
      for (final player in widget.players) player.colorId: player,
    };

    for (var colorId = 0; colorId < 4; colorId++) {
      final player = players[colorId];
      for (var pieceIndex = 0; pieceIndex < 4; pieceIndex++) {
        final node = _tokens[colorId][pieceIndex];
        node.visible = widget.preview || player != null;
        if (!widget.preview && player == null) continue;

        final progress = widget.preview ? -1 : player!.pieces[pieceIndex];
        final key = '$colorId:$pieceIndex';
        final previous = _lastProgress[key];
        final destination = _position(colorId, pieceIndex, progress);
        if (animate && previous != null && previous != progress) {
          _animateToken(
            node,
            _position(colorId, pieceIndex, previous),
            destination,
            colorId,
          );
        } else {
          node.position = _vector(destination);
        }
        _lastProgress[key] = progress;
      }
    }
  }

  TokenPosition _position(int colorId, int pieceIndex, int progress) {
    return LudoBoardGeometry.positionFor(
      colorId: colorId,
      pieceIndex: pieceIndex,
      progress: progress,
    );
  }

  vm.Vector3 _vector(TokenPosition position) {
    return vm.Vector3(position.x, position.y, position.z);
  }

  Future<void> _animateToken(
    Node node,
    TokenPosition from,
    TokenPosition to,
    int colorId,
  ) async {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 310),
    );
    void tick() {
      final t = Curves.easeInOutCubic.transform(controller.value);
      final hop = math.sin(t * math.pi) * 0.54;
      node.position = vm.Vector3(
        from.x + (to.x - from.x) * t,
        from.y + (to.y - from.y) * t + hop,
        from.z + (to.z - from.z) * t,
      );
      node.rotation = vm.Quaternion.axisAngle(
        vm.Vector3(0, 1, 0),
        math.sin(t * math.pi) * 0.22 * (colorId.isEven ? 1 : -1),
      );
    }

    controller.addListener(tick);
    await controller.forward();
    node.position = _vector(to);
    node.rotation = vm.Quaternion.identity();
    controller.dispose();
  }

  Future<void> animateDice(int value) async {
    final dice = _dice;
    if (dice == null) return;
    final finalRotation = _faceRotation(value);
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 790),
    );
    void tick() {
      final t = Curves.easeOutCubic.transform(controller.value);
      final xSpin = vm.Quaternion.axisAngle(
        vm.Vector3(1, 0, 0),
        math.pi * 4.0 * (1 - t),
      );
      final zSpin = vm.Quaternion.axisAngle(
        vm.Vector3(0, 0, 1),
        math.pi * 5.0 * (1 - t),
      );
      dice.rotation = xSpin * zSpin * finalRotation;
      final scale = 1 + math.sin(t * math.pi) * 0.18;
      dice.scale = vm.Vector3.all(scale);
      dice.position = vm.Vector3(0, 1.18 + math.sin(t * math.pi) * 0.65, 8.65);
    }

    controller.addListener(tick);
    await controller.forward();
    dice.rotation = finalRotation;
    dice.scale = vm.Vector3.all(1);
    dice.position = vm.Vector3(0, 1.18, 8.65);
    controller.dispose();
  }

  vm.Quaternion _faceRotation(int value) {
    return switch (value) {
      1 => vm.Quaternion.axisAngle(vm.Vector3(0, 0, 1), math.pi / 2),
      2 => vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), math.pi),
      3 => vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), math.pi / 2),
      4 => vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), -math.pi / 2),
      5 => vm.Quaternion.identity(),
      _ => vm.Quaternion.axisAngle(vm.Vector3(0, 0, 1), -math.pi / 2),
    };
  }

  @override
  void dispose() {
    for (final group in _tokens) {
      group.clear();
    }
    _scene?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scene;
    if (_loading) return const _LoadingWorld();
    if (_error != null || scene == null) {
      return _SceneFailure(message: _error ?? 'Cena 3D indisponível.');
    }

    return GestureDetector(
      onScaleStart: widget.orbitEnabled ? (_) => _pinchStart = _zoom : null,
      onScaleUpdate: widget.orbitEnabled
          ? (details) {
              setState(() {
                _yaw += details.focalPointDelta.dx * 0.003;
                if (details.pointerCount > 1) {
                  _zoom = (_pinchStart / details.scale).clamp(0.82, 1.24);
                }
              });
            }
          : null,
      child: SceneView(
        scene,
        cameraBuilder: (_) => PerspectiveCamera(
          position: vm.Vector3(
            math.sin(_yaw) * 23.5 * _zoom,
            21.0 * _zoom,
            math.cos(_yaw) * 23.5 * _zoom,
          ),
          target: vm.Vector3(0, 0.36, 0),
          fovRadiansY: 0.88,
          fovNear: 0.1,
          fovFar: 100,
        ),
        pixelRatio: widget.pixelRatio,
        maxFrameRate: widget.maxFrameRate,
        warmUp: true,
      ),
    );
  }
}

class _LoadingWorld extends StatelessWidget {
  const _LoadingWorld();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF061326),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: Color(0xFFF0C66E),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'A CARREGAR O MUNDO 3D',
            style: TextStyle(
              color: Color(0xFFC7D4E7),
              letterSpacing: 1.8,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneFailure extends StatelessWidget {
  const _SceneFailure({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF061326),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        'Não foi possível abrir o mundo 3D.\n$message',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFFFFB9C0)),
      ),
    );
  }
}
