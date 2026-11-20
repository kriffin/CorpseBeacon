local T, ns = CBT, CBT.ns
local db, W, b = ns.db, ns.widgets, CBT.beacon
T.sim.present = true
for _, key in ipairs({ "iconSkin", "iconLoot" }) do
	T.sim.skinnable = key == "iconSkin"
	local bad = {}
	for _, icon in ipairs(ns.ICONS) do
		local picked = T.pick(W[key], icon.key)
		ns.Refresh()
		local want = T.texOf(icon.texture)
		local got = T.tex:GetTexture()
		local shown = W[key]:GetText() or ""
		local ringOk = T.icon.ring:IsShown() == (icon.ringed and true or false)
		if not (picked and db[key] == icon.key and want ~= nil and got == want and ringOk and shown:find(icon.name, 1, true)) then
			bad[#bad + 1] = icon.key .. "(" .. tostring(db[key]) .. "," .. tostring(got) .. "/" .. tostring(want) .. ")"
		end
	end
	T.check(key .. " : les " .. #ns.ICONS .. " icônes se choisissent et s'affichent sur la balise", #bad == 0, table.concat(bad, " "))
end
T.pick(W.iconSkin, "skinning")
T.pick(W.iconLoot, "loot")
T.sim.skinnable = true
ns.Refresh()
T.check("cadavre dépeçable -> icône du métier Dépeçage, ronde, dans l'anneau", T.tex:GetTexture() == T.texOf(ns.IconTexture("skinning")) and T.icon.ring:IsShown() and T.icon.masked == true)
T.check("icône du dépeçage = celle du sort 8613 du jeu", ns.IconTexture("skinning") == C_Spell.GetSpellTexture(8613) and ns.Icon("skinning").name == C_Spell.GetSpellName(8613))
local badRing = {}
for _, ring in ipairs(ns.RINGS) do
	local picked = T.pick(W.ring, ring.key)
	ns.Refresh()
	local r = T.icon.ring
	local drawn = ring.atlas and (r:GetAtlas() == ring.atlas) or (r:GetTexture() ~= nil and r:GetTexture() == T.texOf(ring.file))
	local sized = math.abs(r:GetWidth() - db.size * ring.scale) < 0.6 and math.abs(T.tex:GetWidth() - db.size * ring.icon) < 0.6
	if not (picked and db.ring == ring.key and r:IsShown() and drawn and sized and (W.ring:GetText() or "") == ring.name) then
		badRing[#badRing + 1] = ring.key .. "(" .. tostring(db.ring) .. "," .. tostring(drawn) .. "," .. tostring(sized) .. ")"
	end
end
T.check("les " .. #ns.RINGS .. " styles d'anneau (textures du jeu) : choix, dessin, taille de l'anneau et de l'icône", #badRing == 0, table.concat(badRing, " "))
T.pick(W.ring, "gold")
ns.Refresh()
T.sim.skinnable = false
ns.Refresh()
T.check("cadavre à butin -> icône de sac dans l'anneau", T.tex:GetTexture() == T.texOf(ns.IconTexture("loot")) and T.icon.ring:IsShown())
T.pick(W.iconLoot, "raid1")
ns.Refresh()
T.check("icône de raid -> pas d'anneau, pas de masque rond", not T.icon.ring:IsShown() and T.icon.masked == false)
T.pick(W.iconLoot, "loot")
T.check("le logo de l'addon se charge comme texture", T.texOf(ns.LOGO) ~= nil)
T.sim.skinnable = true
ns.Refresh()
return T.flush()
