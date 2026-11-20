local T, ns = CBT, CBT.ns
ns.Refresh()
T.check("10 s après l'essai -> balise masquée toute seule", not T.beacon:IsShown())
-- Réglages non par défaut, à retrouver après rechargement de l'interface.
ns.widgets.size:SetValue(150)
T.pick(ns.widgets.soundId, 3081)
T.pick(ns.widgets.iconSkin, "logo")
T.set(ns.widgets.skinOnly, true)
ns.db.savedCVars = T.savedCVars
return T.flush() .. "\n#BILAN " .. T.ok .. " " .. T.ko
