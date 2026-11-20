local T, ns = CBT, CBT.ns
local db, W, b = ns.db, ns.widgets, CBT.beacon
W.sound:Click()
T.check("Son décoché -> réglage faux", db.sound == false)
T.sounds = {}
T.sim.present = true
ns.Refresh()
T.check("Son décoché -> aucun son à l'apparition", b:IsShown() and #T.sounds == 0, #T.sounds)
T.sim.present = false
ns.Refresh()
W.sound:Click()
T.check("Son recoché -> réglage vrai", db.sound == true)
-- Liste des sons : volume général coupé le temps de les passer tous.
local vol = GetCVar("Sound_MasterVolume")
SetCVar("Sound_MasterVolume", 0)
local ok, err = pcall(function()
	local bad = {}
	for _, s in ipairs(ns.SOUNDS) do
		-- Présence du son vérifiée AVANT le choix : le jeu refuse de rejouer certains sons deux fois
		-- dans la même image (8959, 3081…), le second appel renverrait nil à tort.
		local will, handle = PlaySound(s.id, "Master")
		if handle then StopSound(handle) end
		T.sounds = {}
		local picked = T.pick(W.soundId, s.id)
		if not (picked and db.soundId == s.id and T.sounds[1] == s.id and will and (W.soundId:GetText() or "") == s.name) then
			bad[#bad + 1] = s.id .. "(" .. tostring(db.soundId) .. "," .. tostring(T.sounds[1]) .. "," .. tostring(will) .. ")"
		end
	end
	T.check("les " .. #ns.SOUNDS .. " sons : choix enregistré, son joué au choix, présent dans le jeu, nom affiché", #bad == 0, table.concat(bad, " "))
	T.pick(W.soundId, 3081)
	T.sounds = {}
	W.test:Click()
	T.check("bouton Tester -> joue le son choisi", T.sounds[1] == 3081, table.concat(T.sounds, ","))
end)
SetCVar("Sound_MasterVolume", vol)
T.check("passage de la liste des sons sans erreur", ok, err)
T.check("volume général remis", GetCVar("Sound_MasterVolume") == vol)
return T.flush()
