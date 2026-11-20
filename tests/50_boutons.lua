local T, ns = CBT, CBT.ns
local db, W, b = ns.db, ns.widgets, CBT.beacon
-- Tout dérégler, puis « Réglages par défaut ».
T.set(W.enabled, false)
T.set(W.skinOnly, true)
T.set(W.sound, false)
T.set(W.pulse, false)
T.pick(W.iconSkin, "logo")
T.pick(W.iconLoot, "raid7")
T.pick(W.soundId, 888)
W.size:SetValue(200)
W.offset:SetValue(100)
W.alpha:SetValue(0.5)
W.range:SetValue(20)
SetCVar("Sound_MasterVolume", GetCVar("Sound_MasterVolume"))
W.reset:Click()
local bad = {}
for k, v in pairs(ns.DEFAULTS) do
	if db[k] ~= v then bad[#bad + 1] = k .. "=" .. tostring(db[k]) end
end
T.check("Réglages par défaut -> les 11 réglages reviennent", #bad == 0, table.concat(bad, " "))
local w = W.enabled:GetChecked() and not W.skinOnly:GetChecked() and W.sound:GetChecked() and W.pulse:GetChecked()
	and W.size:GetValue() == 110 and W.offset:GetValue() == 0 and W.range:GetValue() == 60 and math.abs(W.alpha:GetValue() - 1) < 0.01
T.check("Réglages par défaut -> cases et curseurs resynchronisés", w and true or false)
local names = (W.iconSkin:GetText() or "") .. "|" .. (W.iconLoot:GetText() or "") .. "|" .. (W.soundId:GetText() or "")
T.check("Réglages par défaut -> listes resynchronisées", names:find(RAID_TARGET_8, 1, true) and names:find(RAID_TARGET_1, 1, true) and names:find(ns.SOUNDS[1].name, 1, true) and true or false, names)
T.check("Réglages par défaut -> portée du jeu remise à 60", tonumber(GetCVar("SoftTargetInteractRange")) == 60)
-- Commandes
SlashCmdList.CORPSEBEACON("off")
T.check("/cb off -> désactivé et case décochée", db.enabled == false and not W.enabled:GetChecked())
SlashCmdList.CORPSEBEACON("on")
T.check("/cb on -> activé et case cochée", db.enabled == true and W.enabled:GetChecked() and true or false)
HideUIPanel(SettingsPanel)
SlashCmdList.CORPSEBEACON("")
T.check("/cb -> ouvre la page d'options", SettingsPanel:IsShown() and CorpseBeaconOptionsPanel:IsVisible())
HideUIPanel(SettingsPanel)
CorpseBeacon_OnAddonCompartmentClick()
T.check("menu des addons de la mini-carte -> ouvre la page d'options", SettingsPanel:IsShown() and CorpseBeaconOptionsPanel:IsVisible())
T.check("/cb, /corpsebeacon et /cadavre déclarées", SLASH_CORPSEBEACON1 == "/cb" and SLASH_CORPSEBEACON2 == "/corpsebeacon" and SLASH_CORPSEBEACON3 == "/cadavre")
-- Essai 10 s
T.sim.present = false
ns.Refresh()
T.check("avant l'essai -> balise masquée", not b:IsShown())
T.sounds = {}
W.onTarget:Click()
T.check("Afficher la balise 10 s -> balise affichée", b:IsShown())
T.check("Afficher la balise 10 s -> le son joue", T.sounds[1] == db.soundId, table.concat(T.sounds, ","))
T.set(W.enabled, false)
W.onTarget:Click()
T.check("essai possible même addon désactivé", b:IsShown())
T.set(W.enabled, true)
return T.flush()
