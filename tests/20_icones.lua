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
		if not (picked and db[key] == icon.key and want ~= nil and got == want and shown:find(icon.name, 1, true)) then
			bad[#bad + 1] = icon.key .. "(" .. tostring(db[key]) .. "," .. tostring(got) .. "/" .. tostring(want) .. ")"
		end
	end
	T.check(key .. " : les " .. #ns.ICONS .. " icônes se choisissent et s'affichent sur la balise", #bad == 0, table.concat(bad, " "))
end
T.pick(W.iconSkin, "raid8")
T.pick(W.iconLoot, "raid1")
T.sim.skinnable = true
ns.Refresh()
T.check("cadavre dépeçable -> icône « dépeçable » (crâne)", T.tex:GetTexture() == T.texOf(ns.IconTexture("raid8")))
T.sim.skinnable = false
ns.Refresh()
T.check("cadavre à butin -> icône « butin » (étoile)", T.tex:GetTexture() == T.texOf(ns.IconTexture("raid1")))
T.check("le logo de l'addon se charge comme texture", T.texOf(ns.LOGO) ~= nil)
T.sim.skinnable = true
ns.Refresh()
return T.flush()
