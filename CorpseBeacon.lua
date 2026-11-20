-- Corpse Beacon : repère visuel au-dessus du cadavre interactif le plus proche.
-- Le client ne donne aucune position pour un PNJ (UnitPosition renvoie nil), donc pas de flèche
-- possible. En revanche, avec SoftTargetNameplateInteract=1, le cadavre que le jeu propose à la
-- touche d'interaction reçoit une plaque de nom : on y accroche une grande icône.

local ADDON, ns = ...
local L = ns.L
_G.CorpseBeacon = ns

local UNIT = "softinteract"
local MEDIA = "Interface\\AddOns\\" .. ADDON .. "\\media\\"
local RAID_ICON = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_"

ns.LOGO = MEDIA .. "logo"

ns.DEFAULTS = {
	enabled = true,
	skinOnly = false,
	sound = true,
	soundId = 8959,
	iconSkin = "skinning",
	iconLoot = "loot",
	size = 110,
	offset = 0,
	alpha = 1,
	pulse = true,
	range = 60,
}

-- Icônes proposées. Les deux premières sont des icônes du jeu, affichées rondes dans un anneau
-- épais : celle du métier Dépeçage (sort 8613, nom fourni par le client) et un sac pour le butin.
-- Viennent ensuite le logo et les huit icônes de raid, affichés tels quels.
local SKINNING_SPELL = 8613
ns.ICONS = {
	{
		key = "skinning",
		ringed = true,
		texture = (C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(SKINNING_SPELL)) or "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
		name = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(SKINNING_SPELL)) or "Skinning",
	},
	{ key = "loot", ringed = true, texture = "Interface\\Icons\\INV_Misc_Bag_08", name = LOOT or "Loot" },
	{ key = "logo", texture = ns.LOGO, name = L.ICON_LOGO },
}
for _, n in ipairs({ 8, 1, 2, 3, 4, 5, 6, 7 }) do
	ns.ICONS[#ns.ICONS + 1] = { key = "raid" .. n, texture = RAID_ICON .. n, name = _G["RAID_TARGET_" .. n] or ("Raid " .. n) }
end

-- Sons d'alerte : tous vérifiés présents sur le client Forever (PlaySound renvoie vrai).
ns.SOUNDS = {
	{ id = 8959, name = L.S_RAIDWARNING },
	{ id = 8960, name = L.S_READYCHECK },
	{ id = 18871, name = L.S_ALARM:format(1) },
	{ id = 12867, name = L.S_ALARM:format(2) },
	{ id = 12889, name = L.S_ALARM:format(3) },
	{ id = 3081, name = L.S_WHISPER },
	{ id = 878, name = L.S_QUEST },
	{ id = 3175, name = L.S_PING },
	{ id = 120, name = L.S_COINS },
	{ id = 880, name = L.S_INVITE },
	{ id = 8459, name = L.S_PVPQUEUE },
	{ id = 18019, name = L.S_TOAST },
	{ id = 12197, name = L.S_BOSSEMOTE },
	{ id = 37666, name = L.S_BOSSWHISPER },
	{ id = 5274, name = L.S_AUCTION },
	{ id = 31578, name = L.S_EPIC },
	{ id = 63971, name = L.S_LEGENDARY },
	{ id = 888, name = L.S_LEVELUP },
}

function ns.Icon(key)
	for _, icon in ipairs(ns.ICONS) do
		if icon.key == key then return icon end
	end
	return ns.ICONS[1]
end

function ns.IconTexture(key)
	return ns.Icon(key).texture
end

-- Un affichage d'icône, utilisé par la balise et par l'aperçu des options : l'icône, et pour les
-- icônes « ringed » un masque rond et un anneau épais par-dessus. La pulsation anime le corps
-- entier ; l'opacité réglée reste portée par le cadre parent, les deux se multiplient.
local RING_INSET = 0.13 -- l'icône ronde s'arrête sous le bord intérieur de l'anneau
function ns.CreateIcon(parent)
	local d = { body = CreateFrame("Frame", nil, parent) }
	d.body:SetAllPoints(parent)
	d.tex = d.body:CreateTexture(nil, "ARTWORK")
	d.mask = d.body:CreateMaskTexture()
	d.mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	d.mask:SetAllPoints(d.tex)
	d.ring = d.body:CreateTexture(nil, "OVERLAY")
	d.ring:SetTexture(MEDIA .. "ring")
	d.ring:SetAllPoints(d.body)
	d.ring:SetVertexColor(1, 0.82, 0)
	d.ring:Hide()
	d.pulse = d.body:CreateAnimationGroup()
	d.pulse:SetLooping("BOUNCE")
	local fade = d.pulse:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0.45)
	fade:SetDuration(0.6)
	fade:SetSmoothing("IN_OUT")

	-- size : côté de l'affichage, passé par l'appelant. On ne mesure pas le cadre : accrochée à
	-- une plaque de nom, la balise devient une région restreinte que le client refuse de mesurer.
	function d:Set(key, size)
		local icon = ns.Icon(key)
		self.tex:SetTexture(icon.texture)
		self.tex:ClearAllPoints()
		if icon.ringed then
			local w = size * RING_INSET
			self.tex:SetPoint("TOPLEFT", w, -w)
			self.tex:SetPoint("BOTTOMRIGHT", -w, w)
			self.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- rogne le cadre gris des icônes du jeu
			if not self.masked then
				self.tex:AddMaskTexture(self.mask)
				self.masked = true
			end
		else
			self.tex:SetAllPoints(self.body)
			self.tex:SetTexCoord(0, 1, 0, 1)
			if self.masked then
				self.tex:RemoveMaskTexture(self.mask)
				self.masked = false
			end
		end
		self.ring:SetShown(icon.ringed and true or false)
	end

	function d:SetPulse(on)
		if on then
			if not self.pulse:IsPlaying() then self.pulse:Play() end
		else
			self.pulse:Stop()
			self.body:SetAlpha(1)
		end
	end

	return d
end

function ns.Say(msg)
	print("|cffffd100Corpse Beacon|r : " .. msg)
end

function ns.PlayAlert()
	PlaySound(ns.db.soundId, "Master")
end

local beacon = CreateFrame("Frame", "CorpseBeaconFrame", UIParent)
beacon:SetFrameStrata("HIGH")
beacon:Hide()
local display = ns.CreateIcon(beacon)
ns.beaconIcon = display

local lastSound = 0
ns.testUntil = 0

local function isSkinnable(unit)
	local data = C_TooltipInfo and C_TooltipInfo.GetUnit(unit)
	for _, line in ipairs(data and data.lines or {}) do
		if line.leftText == UNIT_SKINNABLE_LEATHER then
			return true
		end
	end
	return false
end

-- Seul point de contact avec l'unité du jeu : renvoie la plaque de nom du cadavre proposé par le
-- jeu, et s'il est dépeçable. La suite de tests (tests/ingame.sh) le remplace pour simuler un cadavre.
function ns.Probe()
	local plate = C_NamePlate.GetNamePlateForUnit(UNIT)
	if not plate or not UnitIsDead(UNIT) then return nil end
	return plate, isSkinnable(UNIT)
end

local function refresh()
	local db = ns.db
	-- Mode essai : la balise se pose sur la cible du joueur, vivante ou non, pendant quelques secondes.
	local testing = GetTime() < ns.testUntil
	if not db or not (db.enabled or testing) then
		beacon:Hide()
		return
	end
	local plate, skinnable
	if testing then
		plate, skinnable = C_NamePlate.GetNamePlateForUnit("target"), true
	else
		plate, skinnable = ns.Probe()
		if not plate then
			beacon:Hide()
			return
		end
	end
	if db.skinOnly and not skinnable then
		beacon:Hide()
		return
	end
	beacon:SetSize(db.size, db.size)
	beacon:SetAlpha(db.alpha)
	display:Set(skinnable and db.iconSkin or db.iconLoot, db.size)
	beacon:ClearAllPoints()
	if plate then
		beacon:SetParent(plate)
		beacon:SetPoint("BOTTOM", plate, "TOP", 0, db.offset)
	else
		-- Essai sans plaque de nom disponible : la balise s'affiche au milieu de l'écran.
		beacon:SetParent(UIParent)
		beacon:SetPoint("CENTER", UIParent, "CENTER", 0, 140)
	end
	display:SetPulse(db.pulse)
	if not beacon:IsShown() then
		beacon:Show()
		if db.sound and GetTime() - lastSound > 3 then
			lastSound = GetTime()
			ns.PlayAlert()
		end
	end
end

-- Les API d'unité peuvent renvoyer des valeurs secrètes ou échouer sur une plaque restreinte :
-- une erreur ne doit que masquer la balise.
function ns.Refresh()
	if not pcall(refresh) then
		beacon:Hide()
	end
end

-- Essai : sur la plaque de nom de la cible si elle en a une, sinon au milieu de l'écran.
function ns.TestOnTarget()
	ns.testUntil = GetTime() + 10
	beacon:Hide()
	lastSound = 0
	ns.Refresh()
end

-- Réglages du jeu dont l'addon a besoin. Les valeurs d'origine du joueur sont gardées à la
-- première activation et rendues quand il désactive la balise.
local CVARS = { SoftTargetInteract = 3, SoftTargetInteractArc = 2, SoftTargetNameplateInteract = 1 }
local RANGE_CVAR = "SoftTargetInteractRange"

function ns.ApplyCVars()
	if not ns.db.savedCVars then
		local saved = { [RANGE_CVAR] = GetCVar(RANGE_CVAR) }
		for name in pairs(CVARS) do saved[name] = GetCVar(name) end
		ns.db.savedCVars = saved
	end
	for name, value in pairs(CVARS) do SetCVar(name, value) end
	SetCVar(RANGE_CVAR, ns.db.range)
end

function ns.RestoreCVars()
	local saved = ns.db.savedCVars
	if not saved then return end
	for name, value in pairs(saved) do SetCVar(name, value) end
	ns.db.savedCVars = nil
end

function ns.SetEnabled(enabled)
	ns.db.enabled = enabled
	if enabled then ns.ApplyCVars() else ns.RestoreCVars() end
	ns.Refresh()
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
events:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= ADDON then return end
		CorpseBeaconDB = CorpseBeaconDB or {}
		ns.db = CorpseBeaconDB
		for k, v in pairs(ns.DEFAULTS) do
			if ns.db[k] == nil then ns.db[k] = v end
		end
		if ns.InitOptions then ns.InitOptions() end
	elseif event == "PLAYER_LOGIN" then
		if ns.db.enabled then ns.ApplyCVars() end
		-- Un cadavre devient dépeçable une fois vidé, sans événement : on revérifie régulièrement.
		C_Timer.NewTicker(0.5, ns.Refresh)
	else
		ns.Refresh()
	end
end)

SLASH_CORPSEBEACON1 = "/cb"
SLASH_CORPSEBEACON2 = "/corpsebeacon"
SLASH_CORPSEBEACON3 = "/cadavre"
SlashCmdList.CORPSEBEACON = function(msg)
	local cmd = (msg or ""):lower():match("^%s*(.-)%s*$")
	if cmd == "on" or cmd == "off" then
		ns.SetEnabled(cmd == "on")
		if ns.SyncOptions then ns.SyncOptions() end
		ns.Say(ns.db.enabled and L.ENABLED or L.DISABLED)
	elseif cmd == "" and ns.OpenOptions then
		ns.OpenOptions()
	else
		ns.Say(L.HELP)
	end
end

-- Bouton du menu des addons (compartiment de la mini-carte), déclaré dans le .toc.
function CorpseBeacon_OnAddonCompartmentClick()
	if ns.OpenOptions then ns.OpenOptions() end
end
