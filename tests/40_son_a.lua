local T, ns = CBT, CBT.ns
local db, W, b = ns.db, ns.widgets, CBT.beacon
T.set(W.sound, true)
T.pick(W.soundId, 8959)
T.sim.present, T.sim.skinnable = false, true
ns.Refresh()
T.sounds = {}
T.sim.present = true
ns.Refresh()
T.check("Son coché -> le son choisi joue à l'apparition", #T.sounds == 1 and T.sounds[1] == 8959, table.concat(T.sounds, ","))
T.sim.present = false
ns.Refresh()
T.sim.present = true
ns.Refresh()
T.check("deux apparitions en moins de 3 s -> un seul son", #T.sounds == 1, #T.sounds)
T.sim.present = false
ns.Refresh()
return T.flush()
