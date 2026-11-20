#!/usr/bin/env bash
# Suite de tests en jeu de Corpse Beacon, pilotée par le pont (wowbridge).
# Prérequis : WoW lancé, personnage en jeu, hors combat. Durée : ~1 min 15, avec un /reload.
builtin cd "$(dirname "$0")" || exit 1
run() {
	wowbridge eval "$(cat "$1")" 2>&1 | python3 -c '
import sys, json
raw = sys.stdin.read()
try:
    d = json.loads(raw)
except Exception:
    print("ECHEC pont : " + raw.strip()[:300]); sys.exit()
if d.get("ok"):
    print("\n".join(str(x) for x in d.get("ret", [])))
else:
    print("ECHEC erreur Lua : " + str(d.get("error"))[:600])
'
}
out=$(mktemp)
{
	echo "== préparation";         run 00_setup.lua
	echo "== général";             run 10_general.lua
	echo "== icônes";              run 20_icones.lua
	echo "== curseurs et aperçu";  run 30_curseurs.lua
	sleep 3.5
	echo "== son";                 run 40_son_a.lua
	sleep 3.5;                     run 41_son_b.lua
	sleep 3.5;                     run 42_son_c.lua
	echo "== boutons et commandes"; run 50_boutons.lua
	sleep 10.8;                    run 51_essai_fin.lua
	echo "== persistance";         wowbridge reload >/dev/null 2>&1; sleep 15; run 60_persistance.lua
} | tee "$out"
echo "== bilan : $(/usr/bin/grep -c '^OK' "$out") réussis, $(/usr/bin/grep -c '^ECHEC' "$out") échecs, $(/usr/bin/grep -c '^SAUTE' "$out") sautés"
rm -f "$out"
