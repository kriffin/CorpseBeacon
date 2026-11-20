-- Après /reload : les réglages doivent revenir du fichier de sauvegarde.
local ns = CorpseBeacon
local db, W = ns.db, ns.widgets
local log, ok, ko = {}, 0, 0
local function check(name, cond, detail)
	if cond then ok = ok + 1 else ko = ko + 1 end
	log[#log + 1] = (cond and "OK    " or "ECHEC ") .. name .. ((detail ~= nil and not cond) and (" [" .. tostring(detail) .. "]") or "")
end
check("après rechargement -> taille 150, son 3081, logo, filtre conservés", db.size == 150 and db.soundId == 3081 and db.iconSkin == "logo" and db.skinOnly == true, db.size .. "/" .. db.soundId .. "/" .. db.iconSkin .. "/" .. tostring(db.skinOnly))
ns.OpenOptions()
check("après rechargement -> la page d'options affiche ces valeurs", W.size:GetValue() == 150 and W.skinOnly:GetChecked() and (W.iconSkin:GetText() or ""):find(ns.L.ICON_LOGO, 1, true) and true or false)
local missing = {}
for loc, tbl in pairs(ns.locales) do
	for key, text in pairs(ns.locales.enUS) do
		if type(tbl[key]) ~= "string" or tbl[key] == "" then missing[#missing + 1] = loc .. "." .. key end
		local _, a = text:gsub("%%d", "")
		local _, c = (tbl[key] or ""):gsub("%%d", "")
		if a ~= c then missing[#missing + 1] = loc .. "." .. key .. "(%d)" end
	end
end
check("13 langues : toutes les clés présentes, formats identiques", #missing == 0, table.concat(missing, " "))
local n = 0
for _ in pairs(ns.locales) do n = n + 1 end
check("13 codes de langue du client couverts", n == 13, n)
check("langue du client (" .. GetLocale() .. ") servie", ns.L.ENABLE == ns.locales[GetLocale()].ENABLE)
-- Remise en état : réglages par défaut.
W.reset:Click()
local bad = {}
for k, v in pairs(ns.DEFAULTS) do if db[k] ~= v then bad[#bad + 1] = k end end
check("remise en état -> réglages par défaut", #bad == 0, table.concat(bad, " "))
HideUIPanel(SettingsPanel)
return table.concat(log, "\n") .. "\n#BILAN " .. ok .. " " .. ko
