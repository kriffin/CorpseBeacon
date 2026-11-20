-- Prépare la suite : cadavre simulé, espion du son, sauvegarde des réglages.
local ns = CorpseBeacon
if CBT and CBT.realProbe then ns.Probe = CBT.realProbe end
CBT = { ok = 0, ko = 0, log = {}, ns = ns, realProbe = ns.Probe, hooked = CBT and CBT.hooked }
local T = CBT
T.saved = {}
for k, v in pairs(ns.db) do T.saved[k] = v end
-- Les réglages du jeu d'origine mémorisés par l'addon sont remis tels quels en fin de suite.
if ns.db.savedCVars then
	T.savedCVars = {}
	for k, v in pairs(ns.db.savedCVars) do T.savedCVars[k] = v end
end
function T.check(name, cond, detail)
	if cond then T.ok = T.ok + 1 else T.ko = T.ko + 1 end
	T.log[#T.log + 1] = (cond and "OK    " or "ECHEC ") .. name .. ((detail ~= nil and not cond) and (" [" .. tostring(detail) .. "]") or "")
end
function T.flush()
	local s = table.concat(T.log, "\n")
	T.log = {}
	return s
end
-- Cadavre simulé : un cadre fixe tient lieu de plaque de nom.
T.anchor = CreateFrame("Frame", nil, UIParent)
T.anchor:SetSize(10, 10)
T.anchor:SetPoint("CENTER", 0, -120)
T.sim = { present = false, skinnable = true }
ns.Probe = function()
	if T.sim.present then return T.sim.plate or T.anchor, T.sim.skinnable end
	return nil
end
T.sounds = {}
if not T.hooked then
	T.hooked = true
	hooksecurefunc("PlaySound", function(id) if CBT and CBT.sounds then CBT.sounds[#CBT.sounds + 1] = id end end)
end
T.beacon = CorpseBeaconFrame
T.icon = ns.beaconIcon
T.tex = ns.beaconIcon.tex
T.ref = UIParent:CreateTexture()
T.ref:Hide()
function T.texOf(path)
	T.ref:SetTexture(path)
	return T.ref:GetTexture()
end
function T.pick(dd, value)
	dd:GenerateMenu()
	for _, e in dd:GetMenuDescription():EnumerateElementDescriptions() do
		if e:GetData() == value then
			dd:Pick(e, MenuInputContext.None)
			return true
		end
	end
	return false
end
function T.set(cb, wanted)
	if (cb:GetChecked() and true or false) ~= wanted then cb:Click() end
end
ns.OpenOptions()
return "préparé : " .. tostring(SettingsPanel:IsShown()) .. " / panneau visible " .. tostring(CorpseBeaconOptionsPanel:IsVisible())
