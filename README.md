# Ludo Nex — Flutter 3D rebuild

Ludo Nex is being rebuilt as an original offline Android board game with a Flutter/Dart application layer and a real-time 3D renderer.

## 3D stack

- Flutter 3.47+ and Dart.
- Flutter Scene 0.24.3 on Flutter GPU/Impeller.
- Physically based GLB assets, a perspective camera, directional lighting, soft shadows, and animated scene nodes.
- The GLB generator at tools/generate_assets.py creates the board, four distinct player tokens, and the six-sided die.
- The scene build hook converts shipped GLB source files to Flutter Scene's optimized binary scene format.

## Original 3D asset set

- assets/models/nex_board.glb — layered board, four raised home areas, path tiles, safe cells, colored home lanes, and central hub.
- assets/models/token_ruby.glb — ruby red pawn.
- assets/models/token_cyan.glb — cyan pawn.
- assets/models/token_emerald.glb — emerald pawn.
- assets/models/token_solar.glb — solar gold pawn.
- assets/models/dice.glb — six-sided PBR die.

The supplied product screenshots are visual references only. Ludo Nex uses its own board layout, geometry, asset models, material palette, interface, and branding.

## First playable milestone

- Local pass-and-play for 2, 3, or 4 players.
- Play against a basic computer opponent.
- Classic six-to-enter, captures, safe cells, exact finish, and four-piece victory.
- Flutter setup and in-game controls integrated with the live 3D scene.
- No login or online services in this milestone.

## Build without installing Flutter on your phone

The GitHub Actions workflow .github/workflows/flutter-android.yml installs Flutter in the cloud, generates the GLB files, prepares the Android host project, enables Flutter GPU, runs Dart analysis and rule tests, and builds a debug APK.

After a successful run, open **Actions → Build Ludo Nex Flutter 3D Android → Ludo-Nex-Flutter-3D-APK** to download the APK artifact.

## Status

This is a new 3D rebuild on flutter-3d-rebuild, not a finished commercial release. It needs a successful CI build, gameplay testing on a physical Android device, rule-edge-case testing, and low-end device profiling before it is merged into main.
