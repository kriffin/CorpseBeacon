local T, ns = CBT, CBT.ns
T.sounds = {}
T.sim.present = true
ns.Refresh()
T.check("nouveau son choisi (3081) -> c'est lui qui joue à l'apparition", T.sounds[1] == 3081, table.concat(T.sounds, ","))
T.sim.present = false
ns.Refresh()
return T.flush()
