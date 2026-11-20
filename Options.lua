-- Page d'options, enregistrée dans Options > Addons.
local ADDON, ns = ...
local L = ns.L

local COL_LEFT, COL_RIGHT = 16, 336
local syncers = {}
-- Contrôles par nom de réglage, pour la suite de tests.
ns.widgets = {}

local function header(parent, text, x, y)
	local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	fs:SetPoint("TOPLEFT", x, y)
	fs:SetText(text)
	return fs
end

local function label(parent, text, x, y, width)
	local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	fs:SetPoint("TOPLEFT", x, y)
	fs:SetWidth(width or 280)
	fs:SetJustifyH("LEFT")
	fs:SetText(text)
	return fs
end

local function checkbox(parent, text, x, y, key, onChange, tip)
	local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	cb:SetPoint("TOPLEFT", x - 4, y)
	cb.Text:SetFontObject("GameFontHighlight")
	cb.Text:SetText(text)
	cb.Text:SetWidth(260)
	cb.Text:SetJustifyH("LEFT")
	cb:SetScript("OnClick", function(self)
		ns.db[key] = self:GetChecked() and true or false
		if onChange then onChange() end
		ns.Refresh()
		ns.UpdatePreview()
	end)
	if tip then
		cb:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(tip, nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
		cb:SetScript("OnLeave", GameTooltip_Hide)
	end
	syncers[#syncers + 1] = function() cb:SetChecked(ns.db[key]) end
	ns.widgets[key] = cb
	return cb
end

local function slider(parent, text, x, y, key, minV, maxV, step, fmt, onChange)
	local s = CreateFrame("Slider", "CorpseBeaconSlider_" .. key, parent, "OptionsSliderTemplate")
	s:SetPoint("TOPLEFT", x + 4, y - 16)
	s:SetWidth(240)
	s:SetMinMaxValues(minV, maxV)
	s:SetValueStep(step)
	s:SetObeyStepOnDrag(true)
	s.Low:SetText(fmt(minV))
	s.High:SetText(fmt(maxV))
	local function show(v) s.Text:SetText(text .. " : |cffffffff" .. fmt(v) .. "|r") end
	s:SetScript("OnValueChanged", function(_, v)
		v = math.floor(v / step + 0.5) * step
		ns.db[key] = v
		show(v)
		if onChange then onChange() end
		ns.Refresh()
		ns.UpdatePreview()
	end)
	syncers[#syncers + 1] = function()
		s:SetValue(ns.db[key])
		show(ns.db[key])
	end
	ns.widgets[key] = s
	return s
end

local function dropdown(parent, x, y, width, items, key, onChange)
	local dd = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
	dd:SetPoint("TOPLEFT", x, y)
	dd:SetWidth(width)
	dd:SetupMenu(function(_, root)
		for _, item in ipairs(items) do
			root:CreateRadio(item.name,
				function(value) return ns.db[key] == value end,
				function(value)
					ns.db[key] = value
					if onChange then onChange() end
					ns.Refresh()
					ns.UpdatePreview()
				end,
				item.value)
		end
	end)
	syncers[#syncers + 1] = function() dd:GenerateMenu() end
	ns.widgets[key] = dd
	return dd
end

function ns.SyncOptions()
	for _, sync in ipairs(syncers) do sync() end
	ns.UpdatePreview()
end

function ns.UpdatePreview() end

function ns.InitOptions()
	local panel = CreateFrame("Frame", "CorpseBeaconOptionsPanel")
	panel.OnCommit, panel.OnDefault, panel.OnRefresh = function() end, function() end, function() end

	-- En-tête
	local logo = panel:CreateTexture(nil, "ARTWORK")
	logo:SetSize(64, 64)
	logo:SetPoint("TOPLEFT", COL_LEFT, -12)
	logo:SetTexture(ns.LOGO)

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 12, -4)
	title:SetText("Corpse Beacon")

	local version = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	version:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 8, 2)
	version:SetText("v" .. (C_AddOns.GetAddOnMetadata(ADDON, "Version") or "?"))

	local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	subtitle:SetWidth(520)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetText(L.SUBTITLE)

	-- Colonne gauche : général et apparence
	local icons = {}
	for _, icon in ipairs(ns.ICONS) do
		icons[#icons + 1] = { name = "|T" .. icon.texture .. ":16|t " .. icon.name, value = icon.key }
	end

	header(panel, L.GENERAL, COL_LEFT, -96)
	checkbox(panel, L.ENABLE, COL_LEFT, -118, "enabled", function()
		if ns.db.enabled then ns.ApplyCVars() else ns.RestoreCVars() end
	end)
	checkbox(panel, L.SKIN_ONLY, COL_LEFT, -144, "skinOnly", nil, L.SKIN_ONLY_TIP)

	header(panel, L.APPEARANCE, COL_LEFT, -186)
	label(panel, L.ICON_SKIN, COL_LEFT, -212)
	dropdown(panel, COL_LEFT, -228, 240, icons, "iconSkin")
	label(panel, L.ICON_LOOT, COL_LEFT, -262)
	dropdown(panel, COL_LEFT, -278, 240, icons, "iconLoot")

	local function plain(v) return tostring(v) end
	local function percent(v) return math.floor(v * 100 + 0.5) .. " %" end
	slider(panel, L.SIZE, COL_LEFT, -322, "size", 24, 300, 2, plain)
	slider(panel, L.OFFSET, COL_LEFT, -370, "offset", 0, 200, 5, plain)
	slider(panel, L.ALPHA, COL_LEFT, -418, "alpha", 0.2, 1, 0.05, percent)
	checkbox(panel, L.PULSE, COL_LEFT, -464, "pulse")

	-- Colonne droite : aperçu, son, détection
	header(panel, L.PREVIEW, COL_RIGHT, -96)
	local box = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	box:SetPoint("TOPLEFT", COL_RIGHT, -118)
	box:SetSize(250, 112)
	box:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 14,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	box:SetBackdropColor(0.04, 0.07, 0.05, 0.9)
	box:SetBackdropBorderColor(0.6, 0.5, 0.25, 1)

	local previews = {}
	for i, key in ipairs({ "iconSkin", "iconLoot" }) do
		local holder = CreateFrame("Frame", nil, box)
		holder:SetSize(96, 96)
		holder:SetPoint("CENTER", box, "CENTER", i == 1 and -60 or 60, 0)
		local inner = CreateFrame("Frame", nil, holder)
		inner:SetPoint("CENTER")
		previews[i] = { key = key, holder = holder, inner = inner, display = ns.CreateIcon(inner) }
	end

	function ns.UpdatePreview()
		local db = ns.db
		-- L'aperçu garde les proportions : la taille réglée est ramenée à 96 px au maximum.
		local side = math.max(16, math.min(96, db.size * 96 / 300 + 24))
		for _, p in ipairs(previews) do
			p.inner:SetSize(side, side)
			p.display:Set(db[p.key], side)
			p.display:SetPulse(db.pulse)
			p.holder:SetAlpha(db.alpha)
			p.holder:SetShown(p.key == "iconSkin" or not db.skinOnly)
		end
	end

	header(panel, L.SOUND, COL_RIGHT, -246)
	checkbox(panel, L.SOUND_ENABLE, COL_RIGHT, -268, "sound")
	label(panel, L.SOUND_CHOICE, COL_RIGHT, -306)
	local sounds = {}
	for _, sound in ipairs(ns.SOUNDS) do
		sounds[#sounds + 1] = { name = sound.name, value = sound.id }
	end
	local soundDrop = dropdown(panel, COL_RIGHT, -322, 182, sounds, "soundId", ns.PlayAlert)
	local test = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	test:SetPoint("LEFT", soundDrop, "RIGHT", 8, 0)
	test:SetSize(60, 24)
	test:SetText(L.TEST)
	test:SetScript("OnClick", ns.PlayAlert)

	header(panel, L.DETECTION, COL_RIGHT, -366)
	slider(panel, L.RANGE, COL_RIGHT, -392, "range", 5, 100, 5, plain, function()
		if ns.db.enabled then ns.ApplyCVars() end
	end)
	local note = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	note:SetPoint("TOPLEFT", COL_RIGHT, -444)
	note:SetWidth(250)
	note:SetJustifyH("LEFT")
	note:SetText(L.RANGE_NOTE)

	local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	reset:SetPoint("TOPLEFT", COL_LEFT, -504)
	reset:SetSize(200, 24)
	reset:SetText(L.RESET)
	reset:SetScript("OnClick", function()
		for k, v in pairs(ns.DEFAULTS) do ns.db[k] = v end
		ns.ApplyCVars()
		ns.SyncOptions()
		ns.Refresh()
	end)

	local onTarget = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	onTarget:SetPoint("TOPLEFT", COL_RIGHT, -504)
	onTarget:SetSize(250, 24)
	onTarget:SetText(L.TEST_TARGET)
	onTarget:SetScript("OnClick", ns.TestOnTarget)

	ns.widgets.test, ns.widgets.reset, ns.widgets.onTarget, ns.widgets.previews = test, reset, onTarget, previews

	panel:SetScript("OnShow", ns.SyncOptions)
	ns.SyncOptions()

	local category = Settings.RegisterCanvasLayoutCategory(panel, "Corpse Beacon")
	Settings.RegisterAddOnCategory(category)
	ns.categoryID = category:GetID()

	function ns.OpenOptions()
		if InCombatLockdown() then
			ns.Say(L.COMBAT)
			return
		end
		Settings.OpenToCategory(ns.categoryID)
	end
end
