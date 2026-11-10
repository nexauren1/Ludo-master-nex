# Ludo Nex

Ludo Nex is an original, offline-first 3D Ludo game for Android, built with Godot 4.7 and GDScript.

The visual direction uses a deep blue game world, metallic gold details, bright player colors, raised board tiles, and custom procedural 3D pieces. The supplied screenshots are design references only; this project does not copy their artwork, branding, characters, or interface assets.

## Current development foundation

- Godot 4.7 project and Android portrait configuration.
- Procedurally generated 3D board, raised track tiles, four home zones, finish hub, 3D tokens, and an animated 3D die.
- Main menu, setup flow, local mode, computer mode, player count selection, profile, and token finish selection.
- Ludo rules module for entering on six, legal moves, captures, safe squares, exact finish, and win detection.
- Basic computer opponent that prioritizes finishing, captures, and safe squares.
- Android debug APK export workflow through GitHub Actions.

## Play modes planned for the first release

- Local pass-and-play for 2, 3, or 4 players on one device.
- Play against computer opponents.
- Four pieces per player, classic dice movement, safe cells, captures, and exact finish.
- Local profile and cosmetic token finishes.

## Build without installing Godot on your device

The workflow at .github/workflows/android.yml downloads Godot and its export templates on a GitHub-hosted runner, installs the Android build dependencies, and exports a debug APK. Start it from Actions → Build Ludo Nex Android APK → Run workflow after the workflow is available on the default branch, or push a commit to the configured development branch.

The APK is uploaded as the workflow artifact Ludo-Nex-Android-APK.

## Important status

This is an early playable foundation, not a finished commercial game. It still requires an actual Godot CI run, gameplay testing on Android hardware, rule-edge-case testing, performance profiling, audio, accessibility, and release signing. Online play, purchases, ads, tournaments, and cloud accounts are intentionally outside the first offline milestone.
