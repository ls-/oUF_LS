local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

local function PartyHolder_OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if GetDisplayedAllyFrames() == "party" then
			self:Show()
		else
			self:Hide()
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

function UF:CreatePartyHolder()
	local holder = CreateFrame("Frame", "LSPartyHolder", UIParent, "SecureHandlerStateTemplate")
	holder:SetSize(110, (36 + 18) * 5 + 40 * 3)
	holder:RegisterEvent("PLAYER_ENTERING_WORLD")
	holder:SetScript("OnEvent", PartyHolder_OnEvent)

	if CompactRaidFrameManager then
		holder:SetPoint(unpack(C.units.party.point1))
	else
		holder:SetPoint(unpack(C.units.party.point2))
	end

	E:CreateMover(holder)
end

function UF:ConstructPartyFrame(frame, ...)
	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame.rearrangeables = {}

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	bg:SetTexCoord(0 / 512, 110 / 512, 130 / 256, 166 / 256)
	bg:SetAllPoints()

	local cover = CreateFrame("Frame", nil, frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local gloss = cover:CreateTexture(nil, "BACKGROUND", nil, 0)
	gloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	gloss:SetTexCoord(0, 1, 0 / 64, 20 / 64)
	gloss:SetSize(94, 20)
	gloss:SetPoint("CENTER")

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	fg:SetTexCoord(112 / 512, 218 / 512, 160 / 256, 190 / 256)
	fg:SetSize(106, 30)
	fg:SetPoint("BOTTOM", 0, 3)
	frame.Fg = fg

	local fgLeft = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fgLeft:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	fgLeft:SetTexCoord(116 / 512, 130 / 512, 66 / 256, 92 / 256)
	fgLeft:SetSize(14, 26)
	fgLeft:SetPoint("LEFT", 5, 0)

	local fgRight = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fgRight:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	fgRight:SetTexCoord(130 / 512, 144 / 512, 66 / 256, 92 / 256)
	fgRight:SetSize(14, 26)
	fgRight:SetPoint("RIGHT", -5, 0)

	frame.Health = UF:CreateHealthBar(frame, 12, true)
	frame.Health:SetFrameLevel(level + 1)
	frame.Health:SetSize(90, 20)
	frame.Health:SetPoint("CENTER")
	frame.Health.Value:SetJustifyH("RIGHT")
	frame.Health.Value:SetParent(cover)
	frame.Health.Value:SetPoint("RIGHT", -12, 0)
	tinsert(frame.mouseovers, frame.Health)

	frame.HealPrediction = UF:CreateHealPrediction(frame)

	local absrobGlow = cover:CreateTexture(nil, "ARTWORK", nil, 3)
	absrobGlow:SetTexture("Interface\\RAIDFRAME\\Shield-Overshield")
	absrobGlow:SetBlendMode("ADD")
	absrobGlow:SetSize(10, 18)
	absrobGlow:SetPoint("RIGHT", -6, 0)
	absrobGlow:SetAlpha(0)
	frame.AbsorbGlow = absrobGlow

	frame.Power = UF:CreatePowerBar(frame, 10, true)
	frame.Power:SetFrameLevel(level + 4)
	frame.Power:SetSize(62, 2)
	frame.Power:SetPoint("CENTER", 0, -11)
	frame.Power.Value:SetJustifyH("LEFT")
	frame.Power.Value:SetPoint("LEFT")
	frame.Power.Value:SetDrawLayer("OVERLAY", 2)
	tinsert(frame.mouseovers, frame.Power)

	local tubeLeft = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeLeft:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeLeft:SetTexCoord(0 / 32, 12 / 32, 23 / 64, 33 / 64)
	tubeLeft:SetSize(12, 10)
	tubeLeft:SetPoint("LEFT", -10, 0)

	local tubeMiddleTop = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeMiddleTop:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeMiddleTop:SetTexCoord(0, 1, 20 / 64, 23 / 64)
	tubeMiddleTop:SetHeight(3)
	tubeMiddleTop:SetPoint("TOPLEFT", 0, 3)
	tubeMiddleTop:SetPoint("TOPRIGHT", 0, 3)

	local tubeGloss = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeMiddleTop:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeMiddleTop:SetTexCoord(0, 1, 0 / 64, 20 / 64)
	tubeMiddleTop:SetAllPoints()

	local tubeMiddleBottom = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeMiddleBottom:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeMiddleBottom:SetTexCoord(0, 1, 23 / 64, 20 / 64)
	tubeMiddleBottom:SetHeight(3)
	tubeMiddleBottom:SetPoint("BOTTOMLEFT", 0, -3)
	tubeMiddleBottom:SetPoint("BOTTOMRIGHT", 0, -3)

	local tubeRight = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeRight:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeRight:SetTexCoord(20 / 32, 32 / 32, 23 / 64, 33 / 64)
	tubeRight:SetSize(12, 10)
	tubeRight:SetPoint("RIGHT", 10, 0)

	frame.Power.Tube = {
		[1] = tubeLeft,
		[2] = tubeMiddleTop,
		[3] = tubeMiddleBottom,
		[4] = tubeRight,
	}

	frame.PhaseIcon = UF:CreateIcon(cover, "Phase", 14)
	tinsert(frame.mouseovers, frame.PhaseIcon)
	tinsert(frame.rearrangeables, frame.PhaseIcon)

	frame.Leader = UF:CreateIcon(cover, "Leader", 14)
	tinsert(frame.mouseovers, frame.Leader)
	tinsert(frame.rearrangeables, frame.Leader)

	frame.LFDRole = UF:CreateIcon(cover, "LFDRole", 14)
	tinsert(frame.mouseovers, frame.LFDRole)
	tinsert(frame.rearrangeables, frame.LFDRole)

	frame.ReadyCheck = cover:CreateTexture("$parentReadyCheckIcon", "BACKGROUND")
	frame.ReadyCheck:SetSize(32, 32)
	frame.ReadyCheck:SetPoint("CENTER")

	frame.RaidIcon = cover:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 3)
	frame.RaidIcon:SetSize(24, 24)
	frame.RaidIcon:SetPoint("TOP", 0, 22)

	local name = E:CreateFontString(cover, 12, "$parentNameText", true)
	name:SetDrawLayer("ARTWORK", 4)
	name:SetPoint("LEFT", frame, "LEFT", 2, 0)
	name:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
	name:SetPoint("BOTTOM", frame, "TOP", 0, 0)
	frame:Tag(name, "[custom:difficulty][custom:effectivelevel]|r [custom:name]")

	frame.Threat = UF:CreateThreat(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_other", 0 / 512, 56 / 512, 166 / 256, 196 / 256)
	frame.Threat:SetSize(56, 30)
	frame.Threat:SetPoint("TOPLEFT", -3, 3)

	frame.DebuffHighlight = UF:CreateDebuffHighlight(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_other", 56 / 512, 112 / 512, 166 / 256, 196 / 256)
	frame.DebuffHighlight:SetSize(56, 30)
	frame.DebuffHighlight:SetPoint("TOPRIGHT", 3, 3)

	frame.Debuffs = UF:CreateDebuffs(frame, {"TOP", frame, "BOTTOM", 0, 4}, 4)
end
