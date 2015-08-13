local _, ns = ...
local C, E, M = ns.C, ns.E, ns.M

E.NP = {}

local NP = E.NP
local COLORS = M.colors

local tonumber, format, match, unpack, select = tonumber, format, strmatch, unpack, select

local prevNumChildren = 0

NP.plates = {}

local function NamePlate_CreateStatusBar(parent, isCastBar)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetSize(122, 14)
	bar:SetPoint(isCastBar and "BOTTOM" or "TOP", parent, isCastBar and "BOTTOM" or "TOP", 0, isCastBar and 0 or -16)
	bar:SetStatusBarTexture(M.textures.statusbar)
	bar:SetStatusBarColor(unpack(COLORS.darkgray))
	bar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 1)

	if isCastBar then
		E:CreateBorder(bar, 8)
	else
		local fg = bar:CreateTexture(nil, "OVERLAY", nil, 1)
		fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
		fg:SetTexCoord(319 / 512, 449 / 512, 5 / 64, 27 / 64)
		fg:SetSize(130, 22)
		fg:SetPoint("CENTER", 0, 0)
	end

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetAllPoints(bar)
	bg:SetTexture(M.textures.statusbar)
	bg:SetVertexColor(unpack(COLORS.darkgray))
	bar.Bg = bg

	local text = E:CreateFontString(bar, isCastBar and 10 or 12, nil, true, nil)
	text:SetAllPoints(bar)
	text:SetJustifyH(isCastBar and "CENTER" or "RIGHT")
	bar.Text = text

	return bar
end

local function NamePlate_GetColor(r, g, b, a)
	r, g, b, a = tonumber(format("%.2f", r)), tonumber(format("%.2f", g)), tonumber(format("%.2f", b)), tonumber(format("%.2f", a))

	if r == 1 and g == 0 and b == 0 then
		return unpack(COLORS.red)
	elseif r == 0 and g == 1 and b == 0 then
		return unpack(COLORS.green)
	elseif r == 1 and g == 1 and b == 0 then
		return unpack(COLORS.yellow)
	elseif r == 0 and g == 0 and b == 1 then
		return unpack(COLORS.blue)
	else
		return r, g, b, a
	end
end

local function NamePlateHealthBar_Update(self)
	local bar = self.Bar
	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(self:GetValue())
	bar:SetStatusBarColor(NamePlate_GetColor(self:GetStatusBarColor()))

	if bar.Text:IsShown() then
		bar.Text:SetText(E:NumberFormat(self:GetValue()))
	end
end

local function NamePlateCastBar_OnShow(self)
	local bar = self.Bar
	bar.Icon:SetTexture(self.Icon:GetTexture())
	bar.Text:SetText(self.Text:GetText())
	bar:Show()
end

local function NamePlateCastBar_OnHide(self)
	self.Bar:Hide()
end

local function NamePlateCastBar_OnValueChanged(self, value)
	local bar = self.Bar
	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(value)

	if self.Shield:IsShown() then
		bar:SetStatusBarColor(unpack(COLORS.gray))
		bar.Icon:SetDesaturated(true)
		bar.Bg:SetVertexColor(unpack(COLORS.darkgray))
	else
		bar:SetStatusBarColor(unpack(COLORS.darkgray))
		bar.Icon:SetDesaturated(false)
		bar.Bg:SetVertexColor(unpack(COLORS.yellow))
	end
end

local function Sizer_OnSizeChanged(self, x, y)
	local parent = self.Parent
	parent:Hide()
	parent:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", E:Round(x), E:Round(y - 20))
	parent:Show()
end

local function NamePlate_OnShow(self)
	local scale = UIParent:GetEffectiveScale()
	local Overlay, NameText, LevelText, HighLevelIcon, EliteIcon =
		self.Overlay, self.NameText, self.LevelText, self.HighLevelIcon, self.EliteIcon

	Overlay:SetScale(scale)

	local sw, ow = tonumber(format("%d", self:GetWidth())), tonumber(format("%d", Overlay:GetWidth()))
	if sw < ow then
		Overlay:SetScale(scale * 0.7)
	end

	local name = NameText:GetText() or UNKNOWNOBJECT
	local level = HighLevelIcon:IsShown() and -1 or tonumber(LevelText:GetText())
	local color = E:RGBToHEX(GetQuestDifficultyColor((level > 0) and level or 99))

	if HighLevelIcon:IsShown() then
		level = "??"
	end

	if EliteIcon:IsShown() then
		level = level.."+"
	end

	Overlay.Name:SetFormattedText("|cff%s%s|r %s", color, level, name)

	Overlay:Show()
end

local function NamePlate_OnHide(self)
	self.Overlay:Hide()
end

local function HandleNamePlate(self)
	local ArtContainer, NameContainer = self:GetChildren()
	local HealthBar, AbsorbBar, CastBar = ArtContainer:GetChildren() -- doesn't seem to work yet

	local Threat, Border, Highlight, LevelText, HighLevelIcon, RaidTargetIcon, EliteIcon = ArtContainer:GetRegions()
	local NameText = NameContainer:GetRegions()
	local HealthBarTexture, OverAbsorb = HealthBar:GetRegions()
	local AbsorbBarTexture, AbsorbBarOverlay = AbsorbBar:GetRegions()
	local CastBarTexture, CastBarBorder, CastBarFrameShield, CastBarSpellIcon, CastBarText, CastBarTextBG = CastBar:GetRegions()

	Border:SetTexture(nil)

	LevelText:SetSize(0.001, 0.001)
	LevelText:Hide()
	self.LevelText = LevelText

	HighLevelIcon:SetTexture(nil)
	self.HighLevelIcon = HighLevelIcon

	EliteIcon:SetAlpha(0)
	self.EliteIcon = EliteIcon

	Highlight:SetTexture(nil)
	self.Highlight = Highlight

	local overlay = CreateFrame("Frame", "LS"..self:GetName().."Overlay", WorldFrame)
	overlay:SetFrameStrata(self:GetFrameStrata())
	overlay:SetSize(120, 48)
	self.Overlay = overlay
	NP.plates[self] = overlay

	HealthBarTexture:SetTexture(nil)

	local MyHealthBar = NamePlate_CreateStatusBar(overlay)
	overlay.Health = MyHealthBar
	HealthBar.Bar = MyHealthBar
	HealthBar:HookScript("OnShow", NamePlateHealthBar_Update)
	HealthBar:HookScript("OnValueChanged", NamePlateHealthBar_Update)

	if not C.nameplates.showText then
		MyHealthBar.Text:Hide()
	end

	if HealthBar:IsShown() then
		NamePlateHealthBar_Update(HealthBar)
	end

	CastBarSpellIcon:SetTexCoord(0, 0, 0, 0)
	CastBarSpellIcon:SetSize(0.001, 0.001)
	CastBar.Icon = CastBarSpellIcon

	CastBarText:Hide()
	CastBar.Text = CastBarText

	CastBarFrameShield:SetTexture(nil)
	CastBar.Shield = CastBarFrameShield

	CastBarTexture:SetTexture(nil)
	CastBarBorder:SetTexture(nil)
	CastBarTextBG:SetTexture(nil)

	local MyCastBar = NamePlate_CreateStatusBar(overlay, true)
	CastBar.Bar = MyCastBar

	local iconHolder = CreateFrame("Frame", nil, MyCastBar)
	iconHolder:SetSize(32, 32)
	iconHolder:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMLEFT", -8, 0)
	E:CreateBorder(iconHolder)

	local icon = iconHolder:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	icon:SetAllPoints()
	MyCastBar.Icon = icon

	CastBar:HookScript("OnShow", NamePlateCastBar_OnShow)
	CastBar:HookScript("OnHide", NamePlateCastBar_OnHide)
	CastBar:HookScript("OnValueChanged", NamePlateCastBar_OnValueChanged)

	if CastBar:IsShown() then
		NamePlateCastBar_OnShow(CastBar)
	else
		MyCastBar:Hide()
	end

	NameText:Hide()
	self.NameText = NameText

	local name = E:CreateFontString(overlay, 14, nil, true, nil)
	name:SetPoint("TOP", overlay, "TOP", 0, 2)
	name:SetPoint("LEFT", overlay, -24, 0)
	name:SetPoint("RIGHT", overlay, 24, 0)
	overlay.Name = name

	RaidTargetIcon:SetParent(overlay)
	RaidTargetIcon:SetSize(32, 32)
	RaidTargetIcon:ClearAllPoints()
	RaidTargetIcon:SetPoint("LEFT", overlay, "RIGHT", 8, 0)

	Threat:SetTexture(nil)
	Threat:Hide()
	self.Threat = Threat

	local threat = MyHealthBar:CreateTexture(nil, "OVERLAY", nil, 0)
	threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	threat:SetTexCoord(62 / 512, 194 / 512, 36 / 64, 60 / 64)
	threat:SetSize(132, 24)
	threat:SetPoint("CENTER", 0, 0)
	threat:Hide()
	overlay.Threat = threat

	local sizer = CreateFrame("Frame", nil, overlay)
	sizer:SetPoint("BOTTOMLEFT", WorldFrame)
	sizer:SetPoint("TOPRIGHT", self, "CENTER")
	sizer:SetScript("OnSizeChanged", Sizer_OnSizeChanged)
	sizer.Parent = overlay

	self:HookScript("OnShow", NamePlate_OnShow)
	self:HookScript("OnHide", NamePlate_OnHide)

	if self:IsShown() then
		NamePlate_OnShow(self)
	else
		overlay:Hide()
	end
end

local function WorldFrame_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		local curNumChildren = WorldFrame:GetNumChildren()

		if curNumChildren ~= prevNumChildren  then
			for i = prevNumChildren + 1, curNumChildren do
				local f = select(i, WorldFrame:GetChildren())

				local name = f:GetName()
				if (name and match(name, "^NamePlate%d")) and not NP.plates[f] then
					HandleNamePlate(f)
				end
			end

			prevNumChildren = curNumChildren
		end

		for plate, overlay in next, NP.plates do
			if plate:IsShown() then
				overlay:SetAlpha(plate:GetAlpha())

				if plate.Threat:IsShown() then
					overlay.Threat:Show()
					overlay.Threat:SetVertexColor(plate.Threat:GetVertexColor())
				else
					overlay.Threat:Hide()

					if plate.Highlight:IsShown() then
						overlay.Name:SetTextColor(unpack(COLORS.yellow))
					else
						overlay.Name:SetTextColor(1, 1, 1)
					end
				end

			end
		end

		self.elapsed = 0
	end
end

function NP:ToggleHealthText()
	for plate, overlay in next, NP.plates do
		if not C.nameplates.showText then
			overlay.Health.Text:Hide()
		else
			overlay.Health.Text:Show()
		end
	end
end

function NP:Initialize()
	WorldFrame:HookScript("OnUpdate", WorldFrame_OnUpdate)
end
