local T, ns = CBT, CBT.ns
local db, W, b = ns.db, ns.widgets, CBT.beacon
T.set(W.enabled, true)
T.set(W.skinOnly, false)
T.sim.present, T.sim.skinnable = true, true
ns.Refresh()
T.check("cadavre dépeçable simulé -> balise affichée", b:IsShown())
-- Réglages du jeu « d'origine » factices, que la désactivation doit rendre tels quels.
db.savedCVars = { SoftTargetInteract = "1", SoftTargetInteractArc = "0", SoftTargetNameplateInteract = "0", SoftTargetInteractRange = "15" }
W.enabled:Click()
T.check("Activer décoché -> réglage faux", db.enabled == false)
T.check("Activer décoché -> balise masquée", not b:IsShown())
local back = GetCVar("SoftTargetInteract") .. "/" .. GetCVar("SoftTargetInteractArc") .. "/" .. GetCVar("SoftTargetNameplateInteract") .. "/" .. GetCVar("SoftTargetInteractRange")
T.check("Activer décoché -> réglages du jeu d'origine rendus", back == "1/0/0/15" and db.savedCVars == nil, back)
W.enabled:Click()
T.check("Activer recoché -> réglages d'origine de nouveau mémorisés", db.savedCVars ~= nil and db.savedCVars.SoftTargetInteractRange == "15")
T.check("Activer recoché -> réglage vrai", db.enabled == true and W.enabled:GetChecked())
T.check("Activer recoché -> balise de retour", b:IsShown())
local cv = GetCVar("SoftTargetInteract") .. "/" .. GetCVar("SoftTargetInteractArc") .. "/" .. GetCVar("SoftTargetNameplateInteract") .. "/" .. GetCVar("SoftTargetInteractRange")
T.check("Activer recoché -> 4 réglages du jeu réappliqués", cv == "3/2/1/" .. db.range, cv)
T.sim.skinnable = false
ns.Refresh()
T.check("filtre coupé -> cadavre à butin seul affiché", b:IsShown())
W.skinOnly:Click()
T.check("Dépeçables seulement coché -> réglage vrai", db.skinOnly == true)
T.check("Dépeçables seulement -> cadavre à butin seul masqué", not b:IsShown())
T.sim.skinnable = true
ns.Refresh()
T.check("Dépeçables seulement -> cadavre dépeçable affiché", b:IsShown())
W.skinOnly:Click()
T.check("Dépeçables seulement décoché -> réglage faux", db.skinOnly == false)
T.sim.present = false
ns.Refresh()
T.check("cadavre ramassé (disparu) -> balise masquée", not b:IsShown())
local plates = C_NamePlate.GetNamePlates()
if plates[1] then
	T.sim.present, T.sim.plate = true, plates[1]
	local ok, err = pcall(ns.Refresh)
	T.check("accroche sur une vraie plaque de nom du jeu", ok and b:IsShown() and b:GetParent() == plates[1], err)
	T.sim.present, T.sim.plate = false, nil
	ns.Refresh()
else
	T.log[#T.log + 1] = "SAUTE accroche sur une vraie plaque de nom (aucune à l'écran)"
end
return T.flush()
