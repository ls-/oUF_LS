local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = _G
local unpack = _G.unpack

-- Mine
local LAYOUT = {
	[0] = {
		sep = {0, 0, 0, 0},
	},
	[1] = {
		[1] = {
			size = 128,
			point = {"BOTTOM", 0, 0},
			glow = {190 / 512, 206 / 512, 1 / 256, 129 / 256},
		},
		sep = {0, 0, 0, 0},
	},
	[2] = {
		[1] = {
			size = 64,
			point = {"BOTTOM", 0, 0},
			glow = {207 / 512, 223 / 512, 65 / 256, 129 / 256},
		},
		[2] = {
			size = 64,
			point = {"BOTTOM", 0, 64},
			glow = {207 / 512, 223 / 512, 1 / 256, 65 / 256},
		},
		sep = {22 / 512, 42 / 512, 1 / 256, 129 / 256},
	},
	[3] = {
		[1] = {
			size = 42,
			point = {"BOTTOM", 0, 0},
			glow = {224 / 512, 240 / 512, 87 / 256, 129 / 256},
		},
		[2] = {
			size = 44,
			point = {"BOTTOM", 0, 42},
			glow = {224 / 512, 240 / 512, 43 / 256, 87 / 256},
		},
		[3] = {
			size = 42,
			point = {"BOTTOM", 0, 86},
			glow = {224 / 512, 240 / 512, 1 / 256, 43 / 256},
		},
		sep = {43 / 512, 63 / 512, 1 / 256, 129 / 256},
	},
	[4] = {
		[1] = {
			size = 32,
			point = {"BOTTOM", 0, 0},
			glow = {241 / 512, 257 / 512, 97 / 256, 129 / 256},
		},
		[2] = {
			size = 32,
			point = {"BOTTOM", 0, 32},
			glow = {241 / 512, 257 / 512, 65 / 256, 97 / 256},
		},
		[3] = {
			size = 32,
			point = {"BOTTOM", 0, 64},
			glow = {241 / 512, 257 / 512, 33 / 256, 65 / 256},
		},
		[4] = {
			size = 32,
			point = {"BOTTOM", 0, 96},
			glow = {241 / 512, 257 / 512, 1 / 256, 33 / 256},
		},
		sep = {64 / 512, 84 / 512, 1 / 256, 129 / 256},
	},
	[5] = {
		[1] = {
			size = 25,
			point = {"BOTTOM", 0, 0},
			glow = {258 / 512, 274 / 512, 104 / 256, 129 / 256},
		},
		[2] = {
			size = 25,
			point = {"BOTTOM", 0, 25},
			glow = {258 / 512, 274 / 512, 79 / 256, 104 / 256},
		},
		[3] = {
			size = 28,
			point = {"BOTTOM", 0, 50},
			glow = {258 / 512, 274 / 512, 51 / 256, 79 / 256},
		},
		[4] = {
			size = 25,
			point = {"BOTTOM", 0, 78},
			glow = {258 / 512, 274 / 512, 26 / 256, 51 / 256},
		},
		[5] = {
			size = 25,
			point = {"BOTTOM", 0, 103},
			glow = {258 / 512, 274 / 512, 1 / 256, 26 / 256},
		},
		sep = {85 / 512, 105 / 512, 1 / 256, 129 / 256},
	},
	[6] = {
		[1] = {
			size = 21,
			point = {"BOTTOM", 0, 0},
			glow = {275 / 512, 291 / 512, 108 / 256, 129 / 256},
		},
		[2] = {
			size = 21,
			point = {"BOTTOM", 0, 21},
			glow = {275 / 512, 291 / 512, 87 / 256, 108 / 256},
		},
		[3] = {
			size = 22,
			point = {"BOTTOM", 0, 42},
			glow = {275 / 512, 291 / 512, 65 / 256, 87 / 256},
		},
		[4] = {
			size = 22,
			point = {"BOTTOM", 0, 64},
			glow = {275 / 512, 291 / 512, 43 / 256, 65 / 256},
		},
		[5] = {
			size = 21,
			point = {"BOTTOM", 0, 86},
			glow = {275 / 512, 291 / 512, 22 / 256, 43 / 256},
		},
		[6] = {
			size = 21,
			point = {"BOTTOM", 0, 107},
			glow = {275 / 512, 291 / 512, 1 / 256, 22 / 256},
		},
		sep = {106 / 512, 126 / 512, 1 / 256, 129 / 256},
	},
	[7] = {
		[1] = {
			size = 18,
			point = {"BOTTOM", 0, 0},
			glow = {292 / 512, 308 / 512, 111 / 256, 129 / 256}
		},
		[2] = {
			size = 18,
			point = {"BOTTOM", 0, 18},
			glow = {292 / 512, 308 / 512, 93 / 256, 111 / 256}
		},
		[3] = {
			size = 18,
			point = {"BOTTOM", 0, 36},
			glow = {292 / 512, 308 / 512, 75 / 256, 93 / 256}
		},
		[4] = {
			size = 20,
			point = {"BOTTOM", 0, 54},
			glow = {292 / 512, 308 / 512, 55 / 256, 75 / 256}
		},
		[5] = {
			size = 18,
			point = {"BOTTOM", 0, 74},
			glow = {292 / 512, 308 / 512, 37 / 256, 55 / 256}
		},
		[6] = {
			size = 18,
			point = {"BOTTOM", 0, 92},
			glow = {292 / 512, 308 / 512, 19 / 256, 37 / 256}
		},
		[7] = {
			size = 18,
			point = {"BOTTOM", 0, 110},
			glow = {292 / 512, 308 / 512, 1 / 256, 19 / 256}
		},
		sep = {127 / 512, 147 / 512, 1 / 256, 129 / 256},
	},
	[8] = {
		[1] = {
			size = 16,
			point = {"BOTTOM", 0, 0},
			glow = {309 / 512, 325 / 512, 113 / 256, 129 / 256}
		},
		[2] = {
			size = 16,
			point = {"BOTTOM", 0, 16},
			glow = {309 / 512, 325 / 512, 97 / 256, 113 / 256}
		},
		[3] = {
			size = 16,
			point = {"BOTTOM", 0, 32},
			glow = {309 / 512, 325 / 512, 81 / 256, 97 / 256}
		},
		[4] = {
			size = 16,
			point = {"BOTTOM", 0, 48},
			glow = {309 / 512, 325 / 512, 65 / 256, 81 / 256}
		},
		[5] = {
			size = 16,
			point = {"BOTTOM", 0, 64},
			glow = {309 / 512, 325 / 512, 49 / 256, 65 / 256}
		},
		[6] = {
			size = 16,
			point = {"BOTTOM", 0, 80},
			glow = {309 / 512, 325 / 512, 33 / 256, 49 / 256}
		},
		[7] = {
			size = 16,
			point = {"BOTTOM", 0, 96},
			glow = {309 / 512, 325 / 512, 17 / 256, 33 / 256}
		},
		[8] = {
			size = 16,
			point = {"BOTTOM", 0, 112},
			glow = {309 / 512, 325 / 512, 1 / 256, 17 / 256}
		},
		sep = {148 / 512, 168 / 512, 1 / 256, 129 / 256},
	},
	[9] = {
		[1] = {
			size = 14,
			point = {"BOTTOM", 0, 0},
			glow = {326 / 512, 342 / 512, 115 / 256, 129 / 256}
		},
		[2] = {
			size = 14,
			point = {"BOTTOM", 0, 14},
			glow = {326 / 512, 342 / 512, 101 / 256, 115 / 256}
		},
		[3] = {
			size = 14,
			point = {"BOTTOM", 0, 28},
			glow = {326 / 512, 342 / 512, 101 / 256, 115 / 256}
		},
		[4] = {
			size = 14,
			point = {"BOTTOM", 0, 42},
			glow = {326 / 512, 342 / 512, 73 / 256, 87 / 256}
		},
		[5] = {
			size = 16,
			point = {"BOTTOM", 0, 56},
			glow = {326 / 512, 342 / 512, 57 / 256, 73 / 256}
		},
		[6] = {
			size = 14,
			point = {"BOTTOM", 0, 72},
			glow = {326 / 512, 342 / 512, 43 / 256, 57 / 256}
		},
		[7] = {
			size = 14,
			point = {"BOTTOM", 0, 86},
			glow = {326 / 512, 342 / 512, 29 / 256, 43 / 256}
		},
		[8] = {
			size = 14,
			point = {"BOTTOM", 0, 100},
			glow = {326 / 512, 342 / 512, 15 / 256, 29 / 256}
		},
		[9] = {
			size = 14,
			point = {"BOTTOM", 0, 114},
			glow = {326 / 512, 342 / 512, 1 / 256, 15 / 256}
		},
		sep = {169 / 512, 189 / 512, 1 / 256, 129 / 256},
	},
	[10] = {
		[1] = {
			size = 13,
			point = {"BOTTOM", 0, 0},
			glow = {364 / 512, 380 / 512, 116 / 256, 129 / 256}
		},
		[2] = {
			size = 13,
			point = {"BOTTOM", 0, 13},
			glow = {364 / 512, 380 / 512, 103 / 256, 116 / 256}
		},
		[3] = {
			size = 13,
			point = {"BOTTOM", 0, 26},
			glow = {364 / 512, 380 / 512, 90 / 256, 103 / 256}
		},
		[4] = {
			size = 13,
			point = {"BOTTOM", 0, 39},
			glow = {364 / 512, 380 / 512, 77 / 256, 90 / 256}
		},
		[5] = {
			size = 12,
			point = {"BOTTOM", 0, 52},
			glow = {364 / 512, 380 / 512, 65 / 256, 77 / 256}
		},
		[6] = {
			size = 12,
			point = {"BOTTOM", 0, 64},
			glow = {364 / 512, 380 / 512, 53 / 256, 65 / 256}
		},
		[7] = {
			size = 13,
			point = {"BOTTOM", 0, 76},
			glow = {364 / 512, 380 / 512, 40 / 256, 53 / 256}
		},
		[8] = {
			size = 13,
			point = {"BOTTOM", 0, 89},
			glow = {364 / 512, 380 / 512, 27 / 256, 40 / 256}
		},
		[9] = {
			size = 13,
			point = {"BOTTOM", 0, 102},
			glow = {364 / 512, 380 / 512, 14 / 256, 27 / 256}
		},
		[10] = {
			size = 13,
			point = {"BOTTOM", 0, 115},
			glow = {364 / 512, 380 / 512, 1 / 256, 14 / 256}
		},
		sep = {343 / 512, 363 / 512, 1 / 256, 129 / 256},
	},
}

local inUse = {} -- slots, visible

function UF:Reskin(frame, slots, visible, sender)
	if (slots == inUse.slots and visible == inUse.visible) or (not visible and sender ~= inUse.sender) then return end

	inUse = {slots = slots, visible = visible, sender = sender}

	frame.Cover.Sep:SetTexCoord(unpack(LAYOUT[slots].sep))

	if visible then
		frame.Cover.Tube:Hide()
	else
		frame.Cover.Tube:Show()
	end
end

local function PostUpdateClassPower(bar, _, max, changed, powerType, event)
	if event == "ClassPowerDisable" then
		bar:Hide()
		UF:Reskin(bar:GetParent(), 0, false, "CP")
	else
		if event == "ClassPowerEnable" or event == "RefreshUnit" or changed then
			bar:Show()
			UF:Reskin(bar:GetParent(), max or 10, true, "CP")

			for i = 1, max do
				local element = bar[i]
				element:SetSize(12, LAYOUT[max][i].size)
				element:SetPoint(unpack(LAYOUT[max][i].point))
				element.Texture:SetVertexColor(M.COLORS.POWER[powerType]:GetRGB())

				local glow = element.Glow
				glow:SetSize(16, LAYOUT[max][i].size)
				glow:SetTexCoord(unpack(LAYOUT[max][i].glow))
				glow:SetVertexColor(M.COLORS.POWER.GLOW[powerType]:GetRGB())
			end
		end
	end
end

local function Element_OnShow(self)
	self.OutAnim:Stop()

	if not self.active and not self.InAnim:IsPlaying() then
		self.InAnim:Play()
		self.active = true
	end
end

local function Element_OnHide(self)
	self.InAnim:Stop()

	if self.active and not self.OutAnim:IsPlaying() then
		self.OutAnim:Play()
		self.active = false
	end
end

function UF:CreateClassPowerBar(parent, level)
	local bar = _G.CreateFrame("Frame", "$parentClassPowerBar", parent)
	bar:SetFrameLevel(level)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)
	E:SetBarSkin(bar, "VERTICAL-L")

	for i = 1, 10 do
		local element = _G.CreateFrame("Frame", "$parentElement"..i, bar)
		element:SetFrameLevel(bar:GetFrameLevel())
		element:SetScript("OnShow", Element_OnShow)
		element:SetScript("OnHide", Element_OnHide)
		bar[i] = element

		local texture = element:CreateTexture(nil, "BACKGROUND", nil, 3)
		texture:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		texture:SetAllPoints()
		element.Texture = texture

		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player-classpower")
		glow:SetPoint("CENTER", element, "CENTER", 0, 0)
		glow:SetAlpha(0)
		element.Glow = glow

		local ag = glow:CreateAnimationGroup()
		element.InAnim = ag

		local anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.35)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(2)
		anim:SetDuration(0.15)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = ag:CreateAnimation("Scale")
		anim:SetOrder(1)
		anim:SetDuration(0.35)
		anim:SetFromScale(0.9, 0.9)
		anim:SetToScale(1.1, 1.1)

		ag = glow:CreateAnimationGroup()
		element.OutAnim = ag

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.2)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(2)
		anim:SetDuration(0.2)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = ag:CreateAnimation("Scale")
		anim:SetOrder(1)
		anim:SetDuration(0.2)
		anim:SetFromScale(1.1, 1.1)
		anim:SetToScale(0.9, 0.9)

		element:Hide()
	end

	bar.PostUpdate = PostUpdateClassPower

	return bar
end

local function PostUpdateRuneBar(bar, rune, _, _, _, runeReady)
	if runeReady then
		rune.InAnim:Play()
	end

	if _G.UnitHasVehicleUI("player") then
		bar:Hide()
		UF:Reskin(bar:GetParent(), 0, false, "RUNES")
	else
		bar:Show()
		UF:Reskin(bar:GetParent(), 6, true, "RUNES")
	end
end

function UF:CreateRuneBar(parent, level)
	local bar = _G.CreateFrame("Frame", "$parentRuneBar", parent)
	bar:SetFrameLevel(level)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)
	E:SetBarSkin(bar, "VERTICAL-L")

	for i = 1, 6 do
		local element = _G.CreateFrame('StatusBar', "$parentRune"..i, bar)
		element:SetFrameLevel(bar:GetFrameLevel())
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetOrientation("VERTICAL")
		element:SetSize(12, LAYOUT[6][i].size)
		element:SetPoint(unpack(LAYOUT[6][i].point))
		element:SetStatusBarColor(M.COLORS.POWER.RUNES:GetRGB())
		bar[i] = element

		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetSize(16, LAYOUT[6][i].size)
		glow:SetPoint("BOTTOM", element, "BOTTOM", 0, 0)
		glow:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player-classpower")
		glow:SetVertexColor(M.COLORS.POWER.GLOW.RUNES:GetRGB())
		glow:SetTexCoord(unpack(LAYOUT[6][i].glow))
		glow:SetAlpha(0)
		element.Glow = glow

		local ag = glow:CreateAnimationGroup()
		element.InAnim = ag

		local anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.25)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(2)
		anim:SetDuration(0.25)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = ag:CreateAnimation("Scale")
		anim:SetOrder(1)
		anim:SetDuration(0.33)
		anim:SetFromScale(0.1, 0.1)
		anim:SetToScale(1.1, 1.1)
	end

	bar.PostUpdate = PostUpdateRuneBar

	return bar
end

local function OverrideStaggerBar(self, _, unit)
	if unit and unit ~= self.unit then return end
	local bar = self.Stagger

	local maxHealth = _G.UnitHealthMax("player")
	local stagger = _G.UnitStagger("player")

	bar:SetMinMaxValues(0, maxHealth)
	bar:SetValue(stagger)

	local r, g, b, hex = M.COLORS.POWER.STAGGER:GetRGBHEX(stagger / maxHealth)

	bar:SetStatusBarColor(r, g, b)

	if bar.__owner.isMouseOver then
		bar.Value:SetFormattedText("%s / |cff"..hex.."%s|r", E:NumberFormat(stagger), E:NumberFormat(maxHealth))
	else
		if stagger > 0 then
			bar.Value:SetFormattedText("|cff"..hex.."%s|r", E:NumberFormat(stagger))
		else
			bar.Value:SetText(nil)
		end
	end
end

local function StaggerBar_OnShow(self)
	UF:Reskin(self:GetParent(), 0, true, "STAGGER")
end

local function StaggerBar_OnHide(self)
	UF:Reskin(self:GetParent(), 0, false, "STAGGER")
end

function UF:CreateStaggerBar(parent, level)
	local bar = _G.CreateFrame("StatusBar", "$parentStaggerBar", parent)
	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	bar:SetOrientation("VERTICAL")
	bar:SetFrameLevel(level)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)
	bar:SetScript("OnShow", StaggerBar_OnShow)
	bar:SetScript("OnHide", StaggerBar_OnHide)
	E:SetBarSkin(bar, "VERTICAL-L")
	E:SmoothBar(bar)

	local value = E:CreateFontString(bar, 12, "$parentStaggerValue", true)
	bar.Value = value

	bar.Override = OverrideStaggerBar

	return bar
end
