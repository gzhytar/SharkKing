# Implementační strategie – Shark King (Godot 4, 2D)

Tento dokument popisuje krok‑za‑krokem plán implementace 2D hry „Shark King“ v Godotu na základě specifikace ve `specs/shark_king_game_description.md`. Cílem je dodat rychle hratelný vertikální slice a následně rozšiřovat obsah do plné hry.

## Předpoklady a cíle
- Godot 4.4, render „Forward Plus“ (viz `project.godot`).
- 2D hra s vodním prostředím (průzkum, přežití, boj, evoluce, questy), řízená scénami a komponentami.
- Zdroje hlavní postavy jsou v `res://images`.
- Primární platforma: PC. Cíl FPS: 60.

## Struktura projektu (adresáře a názvy souborů)
- `res://scenes/`
  - `Main.tscn` (hlavní scéna – načítá svět, UI, systémy)
  - `World.tscn` (svět/biomy, parallax, entity spawner)
  - `Player.tscn` (hráč – kořen `CharacterBody2D`)
  - `enemies/` (scény nepřátel a predátorů)
  - `npcs/` (scény přátelských/frakčních bytostí)
  - `ui/` (HUD, menu, mapy, inventář, evoluce)
- `res://scripts/`
  - `core/` (komponenty: `health.gd`, `damage.gd`, `loot.gd`, `state_machine.gd`)
  - `player/` (`player.gd`, `player_input.gd`, `player_combat.gd`)
  - `world/` (`spawn_manager.gd`, `ecosystem.gd`, `biome_manager.gd`)
  - `ai/` (`behavior_controller.gd`, stavy: `idle.gd`, `patrol.gd`, `chase.gd`, `attack.gd`, `flee.gd`)
  - `systems/` (`quest_system.gd`, `faction_system.gd`, `progression.gd`, `save_system.gd`)
  - `ui/` (`hud.gd`, `evolution_menu.gd`)
- `res://images/` (grafika; hlavní postava – single PNG/spritesheet/parts)
- `res://audio/` (SFX, hudba)
- `res://fonts/`
- `res://data/` (JSON/TRES konfigurace – frakce, questy, mutace)
- `res://shaders/` (vodní efekty, barvy, aberace)

## Nastavení projektu
- Project Settings → Display → Window: Width `1280`, Height `720`, Stretch Mode `canvas_items`, Aspect `keep`.
- Input Map (Project Settings → Input Map):
  - `move_up` (W/Up), `move_down` (S/Down), `move_left` (A/Left), `move_right` (D/Right)
  - `dash` (Shift/Space), `bite` (Left Mouse/Enter), `interact` (E)
  - volitelně `pause` (Esc)
- Import (pro 2D malbu/HD art): `Filter = On`, `Mipmaps = On`, `Repeat = Disabled`.
  - Pro pixel art: `Filter = Off`, `Mipmaps = Off`.

## Milník 0: Technický základ (0.5 dne)
1. Vytvořit adresářovou strukturu dle výše.
2. Nastavit Project Settings (okno, stretch, input map).
3. Vytvořit `scenes/Main.tscn` (kořen `Node2D`) a nastavit jako Main Scene.
4. Přidat `World.tscn` a `UI/HUD.tscn`, instancovat do `Main.tscn`.

## Milník 1: Hráč – import a pohyb (1–2 dny)
1. Import postavy z `res://images`:
   - Pokud jeden PNG (statický/idle):
     - `Player.tscn` (root `CharacterBody2D`) → `Sprite2D` → `texture = res://images/<file>.png`.
   - Pokud spritesheet (mřížka):
     - `AnimatedSprite2D` → `SpriteFrames` → „Add frames from a Sprite Sheet“, nastavit sloupce/řádky, vytvořit animace `idle`, `swim`, `dash`, `bite`.
   - Pokud více PNG (různé snímky):
     - `AnimatedSprite2D` → `SpriteFrames` → přetáhnout snímky do animací.
2. `Player.tscn` – uzly:
   - `CharacterBody2D` (root)
   - `AnimatedSprite2D` nebo `Sprite2D`
   - `CollisionShape2D` (tělo – kapsle/obdélník), `Area2D` + `CollisionShape2D` (útok – čelist)
   - `Camera2D` (smoothing, limite dle mapy), `AudioStreamPlayer2D` (SFX), volitelně `Light2D`
3. Pohyb ve vodě (`scripts/player/player.gd`):
   - Vektory vstupu, akcelerace, odpor (drag), max rychlost, krátký dash s cooldownem
   - Otočení podle směru pohybu, modulace animací
4. Kolize a vrstvy/masky: hráč: layer „player“, masky „world“, „enemy“, „pickup“.
5. Animace: mapovat stav → animace (idle/swim/dash/bite). `AnimationTree` nebo jednoduché přepínání.

## Milník 2: Svět a prostředí (1–2 dny)
1. `World.tscn`:
   - `Node2D` (root)
   - `ParallaxBackground` → vrstvy (hlubší moře, korály, bubliny)
   - `TileMap` (pokud budou pevné překážky/útvary), případně dekorativní `Node2D` s instancemi
   - `SpawnManager` (`scripts/world/spawn_manager.gd`) pro kořist/predátory a sběratelné objekty
2. Základní biome manager (`biome_manager.gd`) – zodpovídá za výběr dekorací a parametrů (světlo, barvy, zesílení proudu).
3. Vizuální voda: `CanvasModulate` pro barevný tón, bubliny (Particles2D), jemný shader pro aberaci (později).

## Milník 3: Kořist a základ nepřátel (2–3 dny)
1. Komponenty jádra (`scripts/core`):
   - `health.gd` (HP, signály `died`), `damage.gd` (damage event), `loot.gd` (drop tabulky)
2. Kořist (prey) – `scenes/enemies/prey_fish.tscn`:
   - `CharacterBody2D` + jednoduché chování (swarm/idle, vyhýbání hráči)
3. Nepřítel – malý predátor – `scenes/enemies/predator_small.tscn`:
   - Stavový automat: idle → patrol → chase → attack → flee (nízké HP)
   - Detekce hráče (Area2D), útok kontaktem nebo narážením
4. Boj hráče: `bite` (Area2D), cooldown, způsobení poškození `damage.gd` objektům v dosahu.
5. Sklizeň zdrojů: poražené entity → loot (resource „biomass“/„essence“).

## Milník 4: Progrese a evoluce (2–3 dny)
1. Systém progrese (`systems/progression.gd`): XP, levely, měna pro mutace.
2. Evoluce – strom mutací (data v `res://data/mutations.json` nebo `.tres`):
   - Mutace: rychlost, zdraví, odolnost vůči proudům, přístup do hlubších biomů
   - Aplikace bonusů na hráče (modifikace parametrů)
3. UI: `scenes/ui/EvolutionMenu.tscn` + `evolution_menu.gd`:
   - Přehled mutací, nákup/odemčení, aktivní build
4. Balanc: náklady a efekty, integrace s lootem z Milníku 3.

## Milník 5: Frakce, questy, příběh (3–5 dní)
1. Frakce (delfíni, mečouni, manta ray): `systems/faction_system.gd` – reputace, vztahy.
2. Quest systém (`systems/quest_system.gd`):
   - Typy: doručení, lov, průzkum, obrana
   - Sledování postupu, odměny (měna, mutace, přístup do biomů)
3. NPC scény v `scenes/npcs/` s dialogem (jednoduchý dialogový systém, později rozšíření).
4. Příběhové háčky: aktivace quest řetězců k trůnu.

## Milník 6: Bossové a speciální střety (3–5 dní)
1. Boss scény: Kraken, Abyssal Leviathan, Orca Warlord – každý s unikátními fázemi.
2. Design arén, speciální vzorce útoků, telegrafy a zranitelné fáze.
3. Odměny: unikátní mutace, přístup do nových zón.

## Milník 7: UI, audio, UX (1–2 dny základ, průběžně)
1. HUD (`scenes/ui/HUD.tscn`): HP bar, stamina/oxygen (pokud bude), ukazatel směru cíle, indikace lootu.
2. Map/minimap (později), kompas/marker.
3. Audio: `AudioStreamPlayer`/`AudioStreamPlayer2D` – ambient, plavání, kousnutí, dash; mix a úrovně.
4. Game feel: obrazové otřesy, `Tween` na barvu, bublinové trail efekty.

## Milník 8: Ekosystém (2–3 dny)
1. Jednoduchá simulace: kořist se množí časem, predátoři loví; limity počtu podle biomu.
2. Vliv hráče: vyhubení druhu sníží spawn rate, frakce reagují (reputace).
3. Telemetrie vyvážení: statistiky o počtech entit.

## Milník 9: Ukládání/načítání (1–2 dny)
1. `systems/save_system.gd`: ukládat progresi hráče, vybavení/mutace, stav questů, seed světa.
2. Sloty, autosave při přechodu biomy/po bosovi.

## Milník 10: Optimalizace a build (průběžně, závěr 2–3 dny)
1. Pooling pro entity (spawner), culling mimo kameru.
2. Profilace (Debugger → Profiler); omezit skriptové alokace.
3. Export presets (Windows, Linux), ikony, splash.

---

## Detailní postup – první vertikální slice (1–2 týdny)

### Krok 1: Hráč a kontrola
- Vytvořit `Player.tscn` dle Milníku 1; implementovat `player.gd` se stavovým strojem: `Idle`, `Swim`, `Dash`, `Bite`.
- Mapovat vstupy na pohyb a útok, doladit fyziku (drag, akcelerace, max speed ~ 350–450 px/s, dash ~ 0.15 s, 2–3× rychlost, cooldown 1.0 s).
- Přidat základní SFX a animace (idle/swim/dash/bite).

### Krok 2: Svět a spawner
- `World.tscn`: Parallax + pár dekorací; vymezit hranice světa pro kameru.
- `spawn_manager.gd`: časově řízený spawn kořisti a malých predátorů kolem hráče (v prstenci 800–1400 px).

### Krok 3: Boj a loot
- `bite` hitbox, poškození kořisti/nepřátel, drop měny (biomass/essence).
- `HUD`: ukázat HP, loot count.

### Krok 4: Evoluce – základ
- `progression.gd` + `evolution_menu.gd` – 3 mutace (rychlost, HP, drag resist), jednoduché UI.
- Aplikace mutací (trvalé buffy) a zobrazení stavu v HUD.

### Krok 5: Mini-quest
- NPC „Dolphin Elder“: krátký úkol „odežeň 3 predátory“; odměna: mutace nebo reputace.

---

## Import hlavní postavy z obrázku (rychlý návod)
- Přetáhni soubory postavy do `res://images/` (viz FileSystem v editoru).
- Vyber obrázek → Import panel:
  - Stylizovaný/HD art: `Filter = On`, `Mipmaps = On`, `Repeat = Disabled` → Reimport
  - Pixel art: `Filter = Off`, `Mipmaps = Off`, `Repeat = Disabled` → Reimport
- Vytvoř `Player.tscn` (root `CharacterBody2D`):
  - Přidej `AnimatedSprite2D` a vytvoř `SpriteFrames`:
    - Spritesheet: „Add frames from a Sprite Sheet“, nastavit `columns/rows`, vybrat snímky pro `idle`, `swim`, `dash`, `bite`.
    - Více PNG: přetáhni soubory do příslušných animací.
  - `CollisionShape2D` (CapsuleShape2D) přizpůsob obrázku.
  - `Camera2D` (smoothing: 0.1–0.2), `AudioStreamPlayer2D` (plavání/kousnutí).

## Datové zdroje a konfigurace
- `res://data/mutations.tres` – seznam mutací (název, cena, efekt, ikona)
- `res://data/factions.tres` – frakce a pravidla reputace
- `res://data/quests/*.tres` – definice questů (cíl, podmínky, odměny)

## Testovací scénáře (akceptační kritéria)
- Pohyb: Hráč akceleruje plynule, dash funguje s cooldownem, kamera sleduje plynule.
- Kolize: Hráč nenaráží do dekorací, útok zasahuje jen v dosahu čelistí.
- Boj: Kořist umírá po zásahu, drop se přičte do měny, predátor pronásleduje a ustoupí pod 20 % HP.
- Evoluce: Nákup mutace zvýší příslušný parametr a perzistuje po uložení/načtení.
- Výkon: 60 FPS s 50+ entitami na scéně, bez výrazných skoků v GC.

## Rizika a mitigace
- Škálování obsahu: začít vertikálním slice a použít datově řízené tabulky (TRES/JSON) pro rychlou iteraci.
- AI složitost: začít jednoduchými stavy, později případný Behavior Tree.
- Balanc: přidat telemetrii (počty entit, DPS, TTK) a testovací vizuály.
- Grafika vody: začít s Parallax + CanvasModulate; shadery ladit později.

## Další kroky po slice
- Rozšířit biomy (hlubiny, vulkanické průduchy, korálová města), přidat proudy ovlivňující pohyb.
- Rozšířit frakce, řetězce questů a příběhové volby.
- Přidat boss mechaniky a unikátní kořist.

---

## Krátký to‑do seznam pro start
1. Nastavit okno a Input Map.
2. Vytvořit `Player.tscn`, importovat sprite z `res://images`, nastavit kolize.
3. Implementovat `player.gd` (pohyb ve vodě + dash + bite).
4. `World.tscn` s Parallax a základním spawnerem kořisti.
5. `HUD` s HP a měnou.
6. Jeden nepřítel s jednoduchým AI.
7. Evoluce – 3 základní mutace a UI.
