JAK 2 CO-OP - HOST
==================

The host does NOT host a save: their PC only runs the "relay", which connects to everyone's
game and forwards positions, missions, orbs and gems. Anyone can be the host.
Everyone plays their own save (see the website / README for how to keep saves in step).

Needs Node.js: https://nodejs.org

One-time
--------
1. Install the game like any player (SETUP.bat in the folder above).
2. Someone in another house? Run HOST-TAILSCALE.bat, then invite them from the page it opens.
3. Collect everyone's address (they get it from NETWORK-SETUP.bat) and put it in players.txt:
     Host@127.0.0.1:8111#0       <- your own game (you can rename it)
     Player2@192.168.1.XX:8111   <- same house
     Player3@100.X.X.X:8111      <- other house (Tailscale)
   Remove the leading "#" from the lines you use. Names are what everyone sees in game.

Every session
-------------
1. Everyone runs PLAY.bat (you too, from the folder above).
2. You run START-RELAY.bat and keep its window open.
   It prints "[Name] in game" for each player and every shared mission/orb/gem.

Testing on one PC (two windows, two controllers)
------------------------------------------------
Start two games on different ports from the game folder:
  gk.exe --socketport 8111 --game jak2 -- -boot -fakeiso
  gk.exe --socketport 8112 --game jak2 -- -boot -fakeiso
and in players.txt:
  A@127.0.0.1:8111#0
  B@127.0.0.1:8112#1
