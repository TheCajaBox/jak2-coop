# Jak 2 Co-op

Play **Jak 2 (OpenGOAL)** together: everyone joins the host's game, sees each other in real time, fights the same enemies and shares missions, orbs and gems. Same house or over the internet.

**📖 Step-by-step guide (ES/EN): https://thecajabox.github.io/jak2-coop/**
**⬇ Download: [latest release](https://github.com/TheCajaBox/jak2-coop/releases/latest)**

> Unofficial fan project built on [OpenGOAL](https://github.com/open-goal/jak-project) and [Teamruns](https://github.com/JoKronk/teamruns-jak-project). You need your own Jak 2 ISO; no game files are included. Work in progress: expect rough edges.

[Español](#español) · [English](#english) · [How it works](#how-it-works) · [Building](#building-from-source)

---

## Español

### Qué hace
- 💾 **Partida compartida:** al conectarse, cada jugador **carga la partida del host** (mismas misiones, orbes, armas y punto de control). Su propia partida no se toca: mientras está unido no se autoguarda.
- 👥 **Os veis:** cada jugador aparece como otro Jak, con su nombre, su color y sus animaciones.
- ⚔️ **Enemigos compartidos:** cada enemigo lo controla el jugador más cercano (le ataca a él) y los demás ven una copia que se mueve igual. Los golpes de cualquiera cuentan y las muertes llegan a todos. Más jugadores = enemigos con más vida.
- 🚨 **Guardias de la ciudad:** cerca del host ves sus mismos guardias (también en el minimapa); lejos tienes los tuyos, con la **alerta compartida**.
- 🎯 **Misiones, orbes y gemas compartidos:** lo que consigue uno lo tienen todos; un orbe o gema cogido desaparece para todos.
- 🚪 **Puerta de misión:** las misiones y carreras que empiezan hablando con alguien solo arrancan si estáis juntos (15 m). Si no: "Esperando a …".
- 🌍 Misma red de casa, o por internet con [Tailscale](https://tailscale.com) (gratis, sin abrir puertos).

### Requisitos
- Tu propia **ISO de Jak 2** (PS2). Windows 10/11 64-bit, ~10 GB libres, gráfica con OpenGL 4.3.
- **No** hace falta tener OpenGOAL instalado.
- Solo el host: [Node.js](https://nodejs.org).

### Instalar (cada jugador, una vez)
1. Descomprime `jak2-coop.zip`.
2. Arrastra tu ISO de Jak 2 encima de `SETUP.bat` y espera a `Done!` (10–30 min).
3. Abre `NETWORK-SETUP.bat`: **1** = misma casa que el host, **2** = otra casa (Tailscale; antes acepta la invitación del host).
4. Manda al host la dirección que aparece al final.

### Hostear (una persona)
1. Instala el juego como un jugador más e instala Node.js.
2. ¿Alguien en otra casa? `host\HOST-TAILSCALE.bat` → *Invite users* → manda el enlace.
3. Pon a todos en `host\players.txt` (se crea la primera vez desde `players-ejemplo.txt`). **El primero de la lista es el host:**
   ```
   Host@127.0.0.1:8111#0
   Player2@192.168.1.20:8111
   Player3@100.71.4.12:8111
   ```

### Cada partida
1. El host abre `PLAY.bat` y carga **su** partida. Los demás abren `PLAY.bat` y cargan cualquiera (se cambiará sola a la del host).
2. El host abre `host\START-RELAY.bat` y lo deja abierto.
3. Al terminar, **el host guarda**. La próxima vez los demás vuelven a unirse a esa partida.

### Actualizar
Cierra el juego, descomprime el zip nuevo **encima** de la carpeta y abre `UPDATE.bat` (1–2 min, no pide la ISO). Tus partidas y tu `players.txt` no se tocan.

---

## English

### What it does
- 💾 **Shared save:** on connect, every player **loads the host's save** (same missions, orbs, weapons and checkpoint). Their own save is untouched: autosave is off while joined.
- 👥 **See each other:** every player shows up as another Jak, with their name, color and animations.
- ⚔️ **Shared enemies:** each enemy is driven by the closest player (and attacks them); everyone else sees a copy moving the same way. Anyone's hits count and deaths reach everyone. More players = tougher enemies.
- 🚨 **City guards:** near the host you see the host's guards (minimap included); far away you get your own, with a **shared alert level**.
- 🎯 **Shared missions, orbs and gems:** what one gets, everyone gets; an orb/gem picked up disappears for everyone.
- 🚪 **Mission gate:** missions and races started by talking to someone only start when you're together (15 m). Otherwise: "Waiting for …".
- 🌍 Same home network, or over the internet with [Tailscale](https://tailscale.com) (free, no port forwarding).

### Requirements
- Your own **Jak 2 ISO** (PS2). Windows 10/11 64-bit, ~10 GB free, OpenGL 4.3 GPU.
- OpenGOAL does **not** need to be installed.
- Host only: [Node.js](https://nodejs.org).

### Install (each player, once)
1. Unzip `jak2-coop.zip`.
2. Drag your Jak 2 ISO onto `SETUP.bat` and wait for `Done!` (10–30 min).
3. Run `NETWORK-SETUP.bat`: **1** = same house as the host, **2** = another house (Tailscale; accept the host's invite first).
4. Send the host the address shown at the end.

### Hosting (one person)
1. Install the game like any player and install Node.js.
2. Someone in another house? `host\HOST-TAILSCALE.bat` → *Invite users* → send the link.
3. List everyone in `host\players.txt` (created on first run from `players-ejemplo.txt`). **The first line is the host** (see the example above).

### Every session
1. The host runs `PLAY.bat` and loads **their** save. Everyone else runs `PLAY.bat` and loads any save (it switches to the host's).
2. The host runs `host\START-RELAY.bat` and keeps it open.
3. When you're done, **the host saves**. Next time everyone joins that save again.

### Updating
Close the game, unzip the new zip **over** the folder and run `UPDATE.bat` (1–2 min, no ISO needed). Your saves and `players.txt` are kept.

---

## How it works
- The game (`gk.exe`, an OpenGOAL build from the Teamruns fork) opens a WebSocket on port **8111**.
- `coop/host/coop-relay.js` (Node) connects to every game and forwards each player's state to the others. The first player in `players.txt` is the host.
- **Joining:** when a guest connects, the relay asks the host's game for its save. The host serializes it in memory with `save-game` (never touching disk), the guest loads it with `initialize! 'game`, and `auto-save-user` is blocked for the guest.
- **Players:** remote players are lightweight "puppet" processes using Jak's skeleton (`skel-jchar`), mirroring the exact animation frame. Animations that are lent by a level heap are never used, so unloading a level can't leave a dangling pointer.
- **Enemies:** each placed enemy is owned by the closest player (8 m hysteresis, ties go to the host). The owner runs its AI and sends position, rotation, animation and hit points. Everyone else puts their copy into a `coop-puppet` state (no AI) that mirrors it. Hits on a copy are forwarded and applied by the owner as a real `'attack`. Deaths are synced by entity name. Respawns only come from the host: a guest removes enemies the host has dead and revives the ones it has alive.
- **City guards** come from each game's traffic system, so they aren't entities. Near the host, the guest turns its own guards off and draws `coop-ghost` copies of the host's (hittable, on the minimap). Further away it gets its own back. The city alert level is synced.
- **Pickups** are hooked in `collectable::do-pickup` and sent with the entity's name. Items in areas that aren't loaded yet are queued.
- **Missions** are detected by polling the task list and closed with `task-resolution-close!` when nothing is loading. The **mission gate** is a check on the triangle press in `process-taskable`.

Main code: `goal_src/jak2/engine/mods/` (`mod-coop.gc`, `mod-remote-player.gc`, `mod-custom-code.gc`), small hooks in `enemy.gc`, `collectables.gc`, `game-save.gc` and `process-taskable.gc`, and the network side in `game/multiplayer.cpp`.

### Known limitations
- Vehicles aren't shared: someone driving shows up as their Jak moving.
- Copies of city guards don't attack (only the real ones in each game do).
- Enemies spawned by missions or waves (with no fixed name) aren't shared.
- Missions that start just by walking into an area aren't covered by the mission gate.
- Not split screen: one PC per player.

## Building from source
Windows: Visual Studio 2022 Build Tools (C++ and Clang), CMake and NASM.
```
cmake --preset=Release-windows-clang-static
cmake --build out/build/Release --target gk goalc extractor
```
Then `extractor -g jak2 -e -d -c <your Jak 2 ISO>`. For the relay, run `npm install` in `coop/host/`. The packaging scripts in `coop/tools/` are the ones used to build the release (they use the author's local paths, adjust them).

## Credits
- [OpenGOAL](https://github.com/open-goal/jak-project) (ISC license): the engine and decompilation this is built on.
- [Teamruns](https://github.com/JoKronk/teamruns-jak-project) by JoKronk & Dexz: the multiplayer foundation (socket protocol, multiplayer types).
- ZedB0T: initial Jak 2 groundwork on the `jak2-3-multiplayer-support` branch.

Fan project, not affiliated with Sony Interactive Entertainment or Naughty Dog.
