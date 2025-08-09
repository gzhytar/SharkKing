# Implementation Details – Initial Setup (Shark King)

Date: 2025-08-09

## Scope
Initial project setup per `specs/implementation-strategy.md` (Milestone 0): window/stretch settings, initial directory structure, base scenes, and main scene selection.

## Changes
- `project.godot`
  - Added display settings: viewport 1280×720, stretch mode `canvas_items`, aspect `keep`.
  - Set main scene: `run/main_scene = res://scenes/Main.tscn`.
- Created directory structure:
  - `scenes/`, `scenes/enemies/`, `scenes/npcs/`, `scenes/ui/`
  - `scripts/`, `scripts/core/`, `scripts/player/`, `scripts/world/`, `scripts/ai/`, `scripts/systems/`, `scripts/ui/`
  - `images/`, `audio/`, `fonts/`, `data/`, `shaders/`
- Created base scenes:
  - `scenes/Main.tscn` (Node2D), `scenes/World.tscn` (Node2D), `scenes/ui/HUD.tscn` (CanvasLayer)
  - Wired `World` and `HUD` as instances inside `Main.tscn` via ExtResource ids.
- Created `todo.md` with initial tasks.

## Decisions & Rationale
- Display settings chosen to match plan and provide stable 16:9 baseline.
- Main scene set early to allow immediate run and iteration loop.
- Scene composition: keep `Main` as lightweight loader/composer; `World` and `HUD` evolve independently.
- Used ExtResource ids in `Main.tscn` for valid instancing format.

## Open Questions (awaiting confirmation)
- Input Map: do we serialize default actions into `project.godot` (WASD/arrows for movement, Shift/Space dash, LMB/Enter bite, E interact, Esc pause), or configure via editor? Current state: not added, pending confirmation.

## Ripple Effects
- None expected; files are additive. Running should open `Main.tscn` without errors.

## Next Steps
- After confirmation, add Input Map or leave for editor configuration.
- Start Milestone 1 groundwork: `Player.tscn` scaffold and asset import from `res://images/`.
