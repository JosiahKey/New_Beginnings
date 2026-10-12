# Files Only Used by v0.1.2

These files were reachable in the released game (`v0.1.2`) but are **not reachable** on `new_version`. They were kept during the unused-file cleanup (October 2026) so they can be reviewed later.

**Why they're unreachable now:** in 0.1.2, `Scripts/level_manager.gd` loaded the overworld levels by name, and `next_level.gd` had a `next_level` property telling each exit where to go. On `new_version`, the level manager loads `Scenes/Biomes/Cave/Level1.tscn` instead and `next_level.gd` no longer has that property, so nothing leads to these scenes anymore.

**Before deleting:** decide whether the overworld is coming back. Even if these are deleted, they stay in git history. `git switch -c old-world v0.1.2` gets them back.

## Overworld levels

| File | Used in 0.1.2 by |
|---|---|
| `Scenes/Levels/Overworld.tscn` | `main.tscn`, `level_manager.gd` |
| `Scenes/Levels/Overworld_fromhome.tscn` | `level_manager.gd` |
| `Scenes/Levels/Overworld_fromside.tscn` | `level_manager.gd` |
| `Scenes/Levels/Overworld_fromtop.tscn` | `level_manager.gd` |
| `Scenes/Levels/Overworld2.tscn` | `level_manager.gd` |
| `Scenes/Levels/Overworld2_fromboss.tscn` | `level_manager.gd` |
| `Scenes/Levels/Sidearea.tscn` | `level_manager.gd` |
| `Scenes/Levels/Bossarea.tscn` | `level_manager.gd`. The only non-debug path to the final boss. |

## Only used by those levels

| File | Used in 0.1.2 by |
|---|---|
| `Scenes/Templates/npc2.tscn` | Overworld2 levels (merchant NPC) |
| `Scripts/npc2.gd` | `npc2.tscn` |
| `Resources/merchant.tres` | `npc2.tscn` |
| `Assets/character_assets/npcs/merchant/Idle.png` | `merchant.tres` |
| `Assets/Fonts/DigitalDisco.ttf` | `npc2.tscn` |
| `Assets/art_assets/battleback_Mountains.png` | Combat background, loaded by name when the biome is `Mountains` (Overworld2 levels) |
| `Assets/art_assets/battleback_Woods.png` | Combat background, loaded by name when the biome is `Woods` (Sidearea) |
| `Assets/tile_assets/jewelry_chest.png` | Chest sprite, loaded by name for `Jewelry` chests (Bossarea) |

Each asset above has a matching `.import` file, and `npc2.gd` has a `.uid` file. Delete those together with it.
