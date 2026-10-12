JAK 2 CO-OP (OpenGOAL, based on Teamruns)
==========================================
Full visual guide: https://thecajabox.github.io/jak2-coop/

You need your own Jak 2 (PS2) ISO and ~10 GB free. OpenGOAL doesn't need to be installed.

1. Unzip this folder somewhere, e.g. D:\Games\jak2-coop
2. Drag your Jak 2 ISO onto SETUP.bat and wait for "Done!" (10-30 min, only once).
3. Run NETWORK-SETUP.bat (only once) and accept the admin prompt:
     1 = same house as the host, 2 = another house (Tailscale: accept the host's invite first).
   Send the host the address it shows at the end.
4. Host: install Node.js, read host\HOST-README.txt, list everyone in host\players.txt (first line = host).

Every session: everyone runs PLAY.bat (the host loads THEIR save, others load any save and switch
to the host's automatically), then the host runs host\START-RELAY.bat.
When you're done the host saves. Guests never autosave over their own save while joined.

Updating: close the game, unzip the new zip over the folder, run UPDATE.bat.
