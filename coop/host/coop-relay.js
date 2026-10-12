// Jak 2 co-op relay: connects to every player's game and forwards each player to all the others.
// Only ONE person runs this. Every game must be reachable from this PC (same home network, or a VPN like Tailscale).
//
//   node coop-relay.js Name@host:port[#controller] ...
//
//   node coop-relay.js Me@127.0.0.1:8111#0 Her@192.168.1.20:8111 Friend@100.64.0.7:8111
//   node coop-relay.js A@127.0.0.1:8111#0 B@127.0.0.1:8112#1      (two windows on one PC, two controllers)
//
// #controller is the controller index that game should use (0 = first controller). Leave it off for other PCs.
const path = require("path");
const WebSocket = require(path.join(__dirname, "node_modules", "ws"));

const COLORS = [2, 3, 4, 1, 7, 9, 8, 5]; // blue, red, yellow, green, purple, light-blue, pink, white

const fs = require("fs");
// everything is also appended to relay.log (with times) so a session can be reviewed afterwards
const logFile = path.join(__dirname, "relay.log");
function log(...args) {
  const line = args.join(" ");
  console.log(line);
  try { fs.appendFileSync(logFile, `${new Date().toLocaleString()}  ${line}
`); } catch (e) {}
}
// players come from the command line, or from players.txt (one per line, # comments) next to this script
let playerArgs = process.argv.slice(2);
// first run: players.txt doesn't exist yet (the zip only ships players-ejemplo.txt so updates never overwrite it)
const playersFile = path.join(__dirname, "players.txt");
const exampleFile = path.join(__dirname, "players-ejemplo.txt");
if (playerArgs.length === 0 && !fs.existsSync(playersFile) && fs.existsSync(exampleFile)) {
  fs.copyFileSync(exampleFile, playersFile);
  console.log("Creado players.txt a partir de players-ejemplo.txt: ponle las direcciones de los jugadores.");
}
if (playerArgs.length === 0 && fs.existsSync(path.join(__dirname, "players.txt")))
  // "#" starts a comment at line start or after a space ("Name@ip:8111#0" keeps its controller suffix)
  playerArgs = fs.readFileSync(path.join(__dirname, "players.txt"), "utf8").split(/\r?\n/).map((l) => l.replace(/\s+#.*$|^#.*$/, "").trim()).filter((l) => l);

const games = playerArgs.map((arg, idx) => {
  const m = arg.match(/^(?:([^@]+)@)?([^:#]+):(\d+)(?:#(\d+))?$/);
  if (!m) {
    console.error(`bad player "${arg}", expected Name@host:port[#controller]`);
    process.exit(1);
  }
  return { idx, name: m[1] ?? `Player ${idx + 1}`, host: m[2], port: Number(m[3]), controller: m[4] === undefined ? undefined : Number(m[4]), color: COLORS[idx % COLORS.length] };
});
if (games.length < 2) {
  console.error('Necesitas al menos 2 jugadores en players.txt (quita el "#" de sus lineas).');
  console.error('Need at least 2 players in players.txt (remove the "#" from their lines).');
  process.exit(1);
}

function sendTo(game, payload) {
  if (game.ws && game.ws.readyState === WebSocket.OPEN) game.ws.send(JSON.stringify(payload));
}

function broadcastPlayer(from, player) {
  // key = sender index, the game puts it in slot key+1 (slot 0 is always the local player)
  for (const other of games) if (other !== from) sendTo(other, { players: { [from.idx]: player } });
}

function connect(game) {
  const ws = new WebSocket(`ws://${game.host}:${game.port}`);
  ws.on("open", () => {
    log(`[${game.name}] connected (${game.host}:${game.port})`);
    game.ws = ws;
  });
  ws.on("message", (raw) => {
    const msg = JSON.parse(raw.toString());
    const host = games[0];
    if (msg.connected) {
      log(`[${game.name}] in game` + (game === host ? " (host)" : ""));
      // first player in players.txt is the host: its save and its enemies are the "real" ones
      const setup = { username: game.name, coopRole: game === host ? 1 : 2 };
      if (game.controller !== undefined) setup.controllerPort = game.controller;
      sendTo(game, setup);
      if (game === host) {
        if (games.some((g) => g.needsSave)) sendTo(host, { requestSave: true });
      } else {
        game.needsSave = true;
        log(`[${game.name}] asking ${host.name} for their save`);
        sendTo(host, { requestSave: true });
      }
    }
    if (msg.coopSave && game === host) {
      for (const g of games) {
        if (g !== host && g.needsSave) {
          log(`[${g.name}] joining ${host.name}'s save (${Math.round(msg.coopSave.length * 0.75 / 1024)} KB)`);
          sendTo(g, { coopSave: msg.coopSave });
          g.needsSave = false;
        }
      }
    }
    if (msg.alert !== undefined && game === host) {
      log(`[${host.name}] city alert level ${msg.alert}`);
      for (const g of games) if (g !== host) sendTo(g, { alert: msg.alert });
    }
    if (msg.enemies) {
      // every player sends the enemies it controls (the ones closest to it): each game gets everyone else's
      game.enemies = msg.enemies;
      if (!game.statsAt || Date.now() - game.statsAt > 5000) {
        game.statsAt = Date.now();
        const byKind = [0, 0, 0];
        for (const e of msg.enemies) byKind[e[11] ?? 0] = (byKind[e[11] ?? 0] ?? 0) + 1;
        log(`[${game.name}] sends ${byKind[0]} enemies, ${byKind[1]} guards, ${byKind[2]} vehicles`);
      }
      game.enemiesAt = Date.now();
      for (const g of games) {
        if (g === game) continue;
        const merged = [];
        for (const src of games) {
          if (src !== g && src.enemies && Date.now() - src.enemiesAt < 500) merged.push(...src.enemies);
        }
        sendTo(g, { enemies: merged.slice(0, 64) });
      }
    }
    const pos = msg.position;
    if (!pos) return;

    const player = {
      username: game.name,
      color: game.color,
      mpState: 2, // interactive
      transX: pos.transX, transY: pos.transY, transZ: pos.transZ,
      quatX: pos.quatX, quatY: pos.quatY, quatZ: pos.quatZ, quatW: pos.quatW,
      rotY: pos.rotY,
      currentLevel: pos.currentLevel,
      tgtState: pos.tgtState,
    };
    if (pos.interType) {
      const names = { 7: "mission", 8: "enemy killed", 9: "skull gem", 11: "precursor orb", 16: "hit enemy" };
      if (pos.interType !== 16) log(`[${game.name}] ${names[pos.interType] ?? "interaction " + pos.interType} ${pos.interName ?? ""}`);
      player.interaction = {
        interType: pos.interType, interAmount: pos.interAmount, interStatus: pos.interStatus,
        interName: pos.interName, interParent: pos.interParent, interLevel: pos.interLevel, interCleanup: 0,
      };
    }
    broadcastPlayer(game, player);
  });
  ws.on("close", () => {
    if (game.ws) {
      log(`[${game.name}] disconnected`);
      broadcastPlayer(game, { mpState: 0 });
    }
    game.ws = undefined;
    setTimeout(() => connect(game), 2000);
  });
  ws.on("error", () => {});
}

log("--- relay started --- Waiting for games:", games.map((g) => `${g.name}@${g.host}:${g.port}`).join(", "));
games.forEach(connect);
