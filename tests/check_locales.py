#!/usr/bin/env python3
"""Hors jeu : toutes les langues ont les mêmes clés que enUS, et le code n'utilise que des clés définies."""
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
src = (root / "Locales.lua").read_text(encoding="utf-8")
blocks = {m.group(1): m.group(2) for m in re.finditer(r"T\.(\w+) = \{(.*?)\n\}", src, re.S)}
keys = {loc: set(re.findall(r"^\t(\w+) = ", body, re.M)) for loc, body in blocks.items()}
ref = keys["enUS"]
bad = False
for loc, found in sorted(keys.items()):
    if found != ref:
        print(loc, "missing:", sorted(ref - found), "extra:", sorted(found - ref))
        bad = True
used = set()
for name in ("CorpseBeacon.lua", "Options.lua"):
    used |= set(re.findall(r"\bL\.([A-Z_]+)", (root / name).read_text(encoding="utf-8")))
if used - ref:
    print("undefined keys:", sorted(used - ref))
    bad = True
if ref - used:
    print("unused keys:", sorted(ref - used))
    bad = True
if bad:
    sys.exit(1)
print(len(ref), "keys,", len(keys), "translated locales in sync")
