local T, ns = CBT, CBT.ns
local db, W, b = ns.db, ns.widgets, CBT.beacon
T.sim.present, T.sim.skinnable = true, true
ns.Refresh()
local function near(a, c) return math.abs(a - c) < 0.011 end
local bad = {}
for _, v in ipairs({ 24, 110, 300 }) do
	W.size:SetValue(v)
	if not (db.size == v and near(b:GetWidth(), v) and near(b:GetHeight(), v) and W.size.Text:GetText():find(tostring(v), 1, true)) then
		bad[#bad + 1] = v .. "->" .. tostring(db.size) .. "/" .. tostring(b:GetWidth())
	end
end
T.check("Taille 24 / 110 / 300 -> réglage, balise et libellé", #bad == 0, table.concat(bad, " "))
W.size:SetValue(111)
T.check("Taille 111 -> ramenée au pas de 2", db.size % 2 == 0, db.size)
W.size:SetValue(110)
bad = {}
for _, v in ipairs({ 0, 50, 200 }) do
	W.offset:SetValue(v)
	local _, _, _, _, y = b:GetPoint()
	if not (db.offset == v and near(y or -1, v)) then bad[#bad + 1] = v .. "->" .. tostring(db.offset) .. "/" .. tostring(y) end
end
T.check("Hauteur 0 / 50 / 200 -> réglage et décalage réel de la balise", #bad == 0, table.concat(bad, " "))
W.offset:SetValue(0)
bad = {}
for _, v in ipairs({ 0.2, 0.6, 1 }) do
	W.alpha:SetValue(v)
	if not (near(db.alpha, v) and near(b:GetAlpha(), v)) then bad[#bad + 1] = v .. "->" .. tostring(db.alpha) .. "/" .. tostring(b:GetAlpha()) end
end
T.check("Opacité 20 / 60 / 100 % -> réglage et opacité réelle", #bad == 0, table.concat(bad, " "))
T.check("Opacité -> libellé en pourcentage", W.alpha.Text:GetText():find("100 %", 1, true) ~= nil, W.alpha.Text:GetText())
bad = {}
for _, v in ipairs({ 5, 100, 60 }) do
	W.range:SetValue(v)
	if not (db.range == v and tonumber(GetCVar("SoftTargetInteractRange")) == v) then bad[#bad + 1] = v .. "->" .. tostring(db.range) .. "/" .. tostring(GetCVar("SoftTargetInteractRange")) end
end
T.check("Portée 5 / 100 / 60 -> réglage et réglage du jeu", #bad == 0, table.concat(bad, " "))
local group = T.tex:GetAnimationGroups()
T.set(W.pulse, true)
ns.Refresh()
T.check("Pulsation cochée -> animation en cours", db.pulse == true and group:IsPlaying())
W.pulse:Click()
T.check("Pulsation décochée -> animation arrêtée, icône pleine", db.pulse == false and not group:IsPlaying() and near(T.tex:GetAlpha(), 1))
W.pulse:Click()
T.check("Pulsation recochée -> animation relancée", db.pulse == true and group:IsPlaying())
local p = W.previews
T.check("Aperçu -> même icône que la balise", p[1].texture:GetTexture() == T.tex:GetTexture())
W.alpha:SetValue(0.5)
T.check("Aperçu -> suit l'opacité", near(p[1].holder:GetAlpha(), 0.5))
W.alpha:SetValue(1)
T.set(W.skinOnly, true)
T.check("Aperçu -> icône de butin cachée si « dépeçables seulement »", not p[2].holder:IsShown() and p[1].holder:IsShown())
T.set(W.skinOnly, false)
T.check("Aperçu -> icône de butin de retour", p[2].holder:IsShown())
T.sim.present = false
ns.Refresh()
return T.flush()
