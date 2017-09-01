local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack
local hooksecurefunc = _G.hooksecurefunc

-- Blizz
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local C_ArtifactUI_GetEquippedArtifactInfo = _G.C_ArtifactUI.GetEquippedArtifactInfo
local C_PetBattles_GetBreedQuality = _G.C_PetBattles.GetBreedQuality
local C_PetBattles_GetLevel = _G.C_PetBattles.GetLevel
local C_PetBattles_GetName = _G.C_PetBattles.GetName
local C_PetBattles_GetNumPets = _G.C_PetBattles.GetNumPets
local C_PetBattles_GetXP = _G.C_PetBattles.GetXP
local C_PetBattles_IsInBattle = _G.C_PetBattles.IsInBattle
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = _G.C_Reputation.IsFactionParagon
local CreateFrame = _G.CreateFrame
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetHonorExhaustion = _G.GetHonorExhaustion
local GetNumArtifactTraitsPurchasableFromXP = _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local GetQuestLogCompletionText = _G.GetQuestLogCompletionText
local GetQuestLogIndexByID = _G.GetQuestLogIndexByID
local GetSelectedFaction = _G.GetSelectedFaction
local GetText = _G.GetText
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local HasArtifactEquipped = _G.HasArtifactEquipped
local InActiveBattlefield = _G.InActiveBattlefield
local IsInActiveWorldPVP = _G.IsInActiveWorldPVP
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsWatchingHonorAsXP = _G.IsWatchingHonorAsXP
local IsXPUserDisabled = _G.IsXPUserDisabled
local PlaySound = _G.PlaySound
local SetWatchedFactionIndex = _G.SetWatchedFactionIndex
local SetWatchingHonorAsXP = _G.SetWatchingHonorAsXP
local UnitFactionGroup = _G.UnitFactionGroup
local UnitHonor = _G.UnitHonor
local UnitHonorLevel = _G.UnitHonorLevel
local UnitHonorMax = _G.UnitHonorMax
local UnitLevel = _G.UnitLevel
local UnitPrestige = _G.UnitPrestige
local UnitSex = _G.UnitSex
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

-- Mine
local isInit = false
local bar

local MAX_BARS = 3
local NAME_TEMPLATE = "|cff%s%s|r"
local REPUTATION_TEMPLATE = "%s: |cff%s%s|r"
local BAR_VALUE_TEMPLATE = "%1$s / |cff%3$s%2$s|r"

local CFG = {
	width = 746,
	point = {
		p = "BOTTOM",
		anchor = "UIParent",
		rP = "BOTTOM",
		x = 0,
		y = 4
	},
}

local LAYOUT = {
	[1] = {
		[1] = {
			point = {"TOPLEFT", "LSUIXPBar", "TOPLEFT", 0, 0},
		},
	},
	[2] = {
		[1] = {
			point = {"TOPLEFT", "LSUIXPBar", "TOPLEFT", 0, 0},
		},
		[2] = {
			point = {"TOPLEFT", "LSUIXPBarSegment1", "TOPRIGHT", 0, 0},
		},
	},
	[3] = {
		[1] = {
			point = {"TOPLEFT", "LSUIXPBar", "TOPLEFT", 0, 0},
		},
		[2] = {
			point = {"TOPLEFT", "LSUIXPBarSegment1", "TOPRIGHT", 0, 0},
		},
		[3] = {
			point = {"TOPLEFT", "LSUIXPBarSegment2", "TOPRIGHT", 0, 0},
		},
	},
}

local function UpdateXPBar()
	local index = 0

	if C_PetBattles_IsInBattle() then
		for i = 1, 3 do
			if i < C_PetBattles_GetNumPets(1) then
				local level = C_PetBattles_GetLevel(1, i)

				if level and level < 25 then
					index = index + 1

					local name = C_PetBattles_GetName(1, i)
					local rarity = C_PetBattles_GetBreedQuality(1, i)
					local cur, max = C_PetBattles_GetXP(1, i)
					local r, g, b = M.COLORS.XP:GetRGB()
					local hex = M.COLORS.XP:GetHEX(0.2)

					bar[index].tooltipInfo = {
						header = NAME_TEMPLATE:format(M.COLORS.ITEM_QUALITY[rarity]:GetHEX(), name),
						line1 = {
							text = L["XP_BAR_LEVEL_TOOLTIP"]:format(level)
						},
					}

					bar[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), hex)
					E:SetSmoothedVertexColor(bar[index].Texture, r, g, b)

					bar[index]:SetMinMaxValues(0, max)
					bar[index]:SetValue(cur)
				end
			end
		end
	else
		-- Artefact
		if HasArtifactEquipped() then
			index = index + 1

			local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, tier = C_ArtifactUI_GetEquippedArtifactInfo()
			local points, cur, max = GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, tier)
			local r, g, b = M.COLORS.ARTIFACT:GetRGBHEX()
			local hex = M.COLORS.ARTIFACT:GetHEX(0.2)

			bar[index].tooltipInfo = {
				header = L["ARTIFACT_POWER"],
				line1 = {
					text = L["XP_BAR_ARTIFACT_NUM_UNSPENT_TRAIT_POINTS_TOOLTIP"]:format(points)
				},
				line2 = {
					text = L["XP_BAR_ARTIFACT_NUM_PURCHASED_RANKS_TOOLTIP"]:format(pointsSpent)
				},
			}

			bar[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), hex)
			E:SetSmoothedVertexColor(bar[index].Texture, r, g, b)

			bar[index]:SetMinMaxValues(0, max)
			bar[index]:SetValue(cur)
		end

		-- XP / Honour
		if UnitLevel("player") < MAX_PLAYER_LEVEL then
			if not IsXPUserDisabled() then
				index = index + 1

				local cur, max = UnitXP("player"), UnitXPMax("player")
				local bonus = GetXPExhaustion()
				local r, g, b = M.COLORS.XP:GetRGB()
				local hex = M.COLORS.XP:GetHEX(0.2)

				bar[index].tooltipInfo = {
					header = L["EXPERIENCE"],
					line1 = {
						text = L["XP_BAR_LEVEL_TOOLTIP"]:format(UnitLevel("player"))
					},
				}

				if bonus and bonus > 0 then
					bar[index].tooltipInfo.line2 = {
						text = L["XP_BAR_XP_BONUS_TOOLTIP"]:format(bonus)
					}
				else
					bar[index].tooltipInfo.line2 = nil
				end

				bar[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), hex)
				E:SetSmoothedVertexColor(bar[index].Texture, r, g, b)

				bar[index]:SetMinMaxValues(0, max)
				bar[index]:SetValue(cur)
			end
		else
			if IsWatchingHonorAsXP() or InActiveBattlefield() or IsInActiveWorldPVP() then
				index = index + 1

				local cur, max = UnitHonor("player"), UnitHonorMax("player")
				local bonus = GetHonorExhaustion()
				local r, g, b = M.COLORS.FACTION[UnitFactionGroup("player"):upper()]:GetRGB()
				local hex = M.COLORS.FACTION[UnitFactionGroup("player"):upper()]:GetHEX(0.2)

				bar[index].tooltipInfo = {
					header = L["HONOR"],
					line1 = {
						text = L["XP_BAR_HONOR_TOOLTIP"]:format(UnitHonorLevel("player")),
					},
					line2 = {
						text = L["XP_BAR_PRESTIGE_LEVEL_TOOLTIP"]:format(UnitPrestige("player"))
					},
				}

				if bonus and bonus > 0 then
					bar[index].tooltipInfo.line3 = {
						text = L["XP_BAR_HONOR_BONUS_TOOLTIP"]:format(bonus)
					}
				else
					bar[index].tooltipInfo.line3 = nil
				end

				bar[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), hex)
				E:SetSmoothedVertexColor(bar[index].Texture, r, g, b)

				bar[index]:SetMinMaxValues(0, max)
				bar[index]:SetValue(cur)
			end
		end

		-- Reputation
		local name, standing, repMin, repMax, repCur, factionID = GetWatchedFactionInfo()

		if name then
			index = index + 1

			local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
			local repTextLevel = GetText("FACTION_STANDING_LABEL"..standing, UnitSex("player"))
			local isParagon, rewardQuestID, hasRewardPending
			local cur, max

			if friendRep then
				if nextFriendThreshold then
					max, cur = nextFriendThreshold - friendThreshold, friendRep - friendThreshold
				else
					max, cur = 1, 1
				end

				standing = 5
				repTextLevel = friendTextLevel
			else
				if standing ~= MAX_REPUTATION_REACTION then
					max, cur = repMax - repMin, repCur - repMin
				else
					isParagon = C_Reputation_IsFactionParagon(factionID)

					if isParagon then
						cur, max, rewardQuestID, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
						cur = cur % max
						repTextLevel = repTextLevel.."+"

						if hasRewardPending then
							cur = cur + max
						end
					else
						max, cur = 1, 1
					end
				end
			end

			local r, g, b = M.COLORS.REACTION[standing]:GetRGB()
			local hex = M.COLORS.REACTION[standing]:GetHEX(0.2)

			bar[index].tooltipInfo = {
				header = L["REPUTATION"],
				line1 = {
					text = REPUTATION_TEMPLATE:format(name, hex, repTextLevel)
				},
			}

			if isParagon and hasRewardPending then
				local text = GetQuestLogCompletionText(GetQuestLogIndexByID(rewardQuestID))

				if text and text ~= "" then
					bar[index].tooltipInfo.line3 = {
						text = text
					}
				end
			else
				bar[index].tooltipInfo.line3 = nil
			end

			bar[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), hex)
			E:SetSmoothedVertexColor(bar[index].Texture, r, g, b)

			bar[index]:SetMinMaxValues(0, max)
			bar[index]:SetValue(cur)
		end
	end

	for i = 1, MAX_BARS do
		if i <= index then
			bar[i]:SetSize(unpack(LAYOUT[index][i].size))
			bar[i]:SetPoint(unpack(LAYOUT[index][i].point))
			bar[i]:Show()

			bar[i].Texture.ScrollAnim:Play()
		else
			bar[i]:SetMinMaxValues(0, 1)
			bar[i]:SetValue(0)
			bar[i]:ClearAllPoints()
			bar[i]:Hide()

			bar[i].Texture.ScrollAnim:Stop()
		end
	end

	for i = 1, 2 do
		if i <= index - 1 then
			bar[i].Sep:Show()
		else
			bar[i].Sep:Hide()
		end
	end

	if index == 0 then
		local r, g, b = M.COLORS.CLASS[E.PLAYER_CLASS]:GetRGB()

		bar[1]:SetPoint(unpack(LAYOUT[1][1].point))
		bar[1]:SetSize(unpack(LAYOUT[1][1].size))
		bar[1]:SetMinMaxValues(0, 1)
		bar[1]:SetValue(1)
		bar[1]:Show()

		bar[1].Spark:Hide()
		bar[1].Text:SetText(nil)
		E:SetSmoothedVertexColor(bar[1].Texture, r, g, b)
		bar[1].Texture.ScrollAnim:Play()
	else
		bar[1].Spark:Show()
	end
end

local function SetXPBarStyle(width)
	LAYOUT[1][1].size = {width, 16 / 2}

	local layout = E:CalcLayout(width, 2)

	LAYOUT[2][1].size = {layout[1], 16 / 2}
	LAYOUT[2][2].size = {layout[2], 16 / 2}

	layout = E:CalcLayout(width, 3)

	LAYOUT[3][1].size = {layout[1], 16 / 2}
	LAYOUT[3][2].size = {layout[2], 16 / 2}
	LAYOUT[3][3].size = {layout[3], 16 / 2}

	bar:SetSize(width, 16 / 2)

	local total = 0

	for i = 1, MAX_BARS do
		if bar[i]:IsShown() then
			total = total + 1
		end
	end

	for i = 1, total do
		bar[i]:SetSize(unpack(LAYOUT[total][i].size))
		bar[i]:SetPoint(unpack(LAYOUT[total][i].point))
	end

	UpdateXPBar()
end

local function XPBar_OnEvent(_, event, ...)
	if event == "UNIT_INVENTORY_CHANGED" then
		local unit = ...

		if unit == "player" then
			UpdateXPBar()
		end
	else
		UpdateXPBar()
	end
end

local function Segment_OnEnter(self)
	if self.tooltipInfo then
		local quadrant = E:GetScreenQuadrant(bar)
		local p, rP, sign = "BOTTOMLEFT", "TOPLEFT", 1

		if quadrant == "TOPLEFT" or quadrant == "TOP" or quadrant == "TOPRIGHT" then
			p, rP, sign = "TOPLEFT", "BOTTOMLEFT", -1
		end

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(p, self, rP, 0, sign * 2)
		GameTooltip:AddLine(self.tooltipInfo.header, 1, 1, 1)
		GameTooltip:AddLine(self.tooltipInfo.line1.text)

		if self.tooltipInfo.line2 then
			GameTooltip:AddLine(self.tooltipInfo.line2.text)
		end

		if self.tooltipInfo.line3 then
			GameTooltip:AddLine(self.tooltipInfo.line3.text)
		end

		GameTooltip:Show()
	end

	self.Text:Show()
end

local function Segment_OnLeave(self)
	GameTooltip:Hide()

	self.Text:Hide()
end

function BARS.SetXPBarStyle(_, ...)
	SetXPBarStyle(...)
end

function BARS.HasXPBar()
	return isInit
end

function BARS.CreateXPBar()
	if not isInit and (C.db.char.bars.xpbar.enabled or BARS:IsRestricted()) then
		local config = BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar

		bar = CreateFrame("Frame", "LSUIXPBar", UIParent)
		bar:SetScript("OnEvent", XPBar_OnEvent)
		-- all
		bar:RegisterEvent("PET_BATTLE_CLOSE")
		bar:RegisterEvent("PET_BATTLE_OPENING_START")
		bar:RegisterEvent("PLAYER_UPDATE_RESTING")
		bar:RegisterEvent("UPDATE_EXHAUSTION")
		-- honour
		bar:RegisterEvent("HONOR_LEVEL_UPDATE")
		bar:RegisterEvent("HONOR_XP_UPDATE")
		bar:RegisterEvent("ZONE_CHANGED")
		bar:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		-- ap
		bar:RegisterEvent("ARTIFACT_XP_UPDATE")
		bar:RegisterEvent("UNIT_INVENTORY_CHANGED")
		-- xp
		bar:RegisterEvent("DISABLE_XP_GAIN")
		bar:RegisterEvent("ENABLE_XP_GAIN")
		bar:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
		bar:RegisterEvent("PET_BATTLE_XP_CHANGED")
		bar:RegisterEvent("PLAYER_LEVEL_UP")
		bar:RegisterEvent("PLAYER_XP_UPDATE")
		bar:RegisterEvent("UPDATE_EXPANSION_LEVEL")
		-- rep
		bar:RegisterEvent("UPDATE_FACTION")

		local cover = CreateFrame("Frame", nil, bar)
		cover:SetAllPoints()
		cover:SetFrameLevel(bar:GetFrameLevel() + 3)

		local text_parent = CreateFrame("Frame", nil, bar)
		text_parent:SetAllPoints()
		text_parent:SetFrameLevel(bar:GetFrameLevel() + 5)

		local t = bar:CreateTexture(nil, "ARTWORK")
		t:SetAllPoints()
		t:SetTexture("Interface\\Artifacts\\_Artifacts-DependencyBar-BG", true)
		t:SetHorizTile(true)
		t:SetTexCoord(0 / 128, 128 / 128, 4 / 16, 12 / 16)

		for i = 1, MAX_BARS do
			bar[i] = CreateFrame("StatusBar", "$parentSegment"..i, bar)
			bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
			bar[i]:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
			bar[i]:SetStatusBarColor(0, 0, 0, 0)
			bar[i]:SetHitRectInsets(0, 0, -4, -4)
			bar[i]:SetScript("OnEnter", Segment_OnEnter)
			bar[i]:SetScript("OnLeave", Segment_OnLeave)
			E:SmoothBar(bar[i])
			bar[i]:Hide()

			bar[i].Texture = E:CreateAnimatedLine(bar[i])
			bar[i].Texture:SetFrameLevel(bar[i]:GetFrameLevel() + 1)
			bar[i].Texture:SetAllPoints(bar[i]:GetStatusBarTexture())

			local spark = bar[i]:CreateTexture(nil, "ARTWORK", nil, 1)
			spark:SetSize(16, 16)
			spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			spark:SetBlendMode("ADD")
			spark:SetPoint("CENTER", bar[i]:GetStatusBarTexture(), "RIGHT", 0, 0)
			bar[i].Spark = spark

			local text = text_parent:CreateFontString(nil, "OVERLAY", "LS10Font_Outline")
			text:SetAllPoints(bar[i])
			text:SetWordWrap(false)
			text:Hide()
			bar[i].Text = text
		end

		local sep = cover:CreateTexture(nil, "ARTWORK", nil, -7)
		sep:SetPoint("LEFT", bar[1], "RIGHT", -5, 0)
		sep:SetSize(24 / 2, 16 / 2)
		sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
		sep:SetTexCoord(1 / 64, 25 / 64, 1 / 64, 17 / 64)
		sep:Hide()
		bar[1].Sep = sep

		sep = cover:CreateTexture(nil, "ARTWORK", nil, -7)
		sep:SetPoint("LEFT", bar[2], "RIGHT", -5, 0)
		sep:SetSize(24 / 2, 16 / 2)
		sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
		sep:SetTexCoord(1 / 64, 25 / 64, 1 / 64, 17 / 64)
		sep:Hide()
		bar[2].Sep = sep

		-- Honour & Rep Hooks
		-- This way I'm able to show honour and reputation bars simultaneously
		local isHonorBarHooked = false

		hooksecurefunc("TalentFrame_LoadUI", function()
			if not isHonorBarHooked then
				PlayerTalentFramePVPTalents.XPBar:SetScript("OnMouseUp", function()
					if IsShiftKeyDown() then
						if IsWatchingHonorAsXP() or InActiveBattlefield() or IsInActiveWorldPVP() then
							PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
							SetWatchingHonorAsXP(false)
						else
							PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
							SetWatchingHonorAsXP(true)
						end

						UpdateXPBar()
					end
				end)

				PlayerTalentFramePVPTalents.XPBar:HookScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_TOP")
					GameTooltip:AddLine(L["SHIFT_CLICK_TO_SHOW_AS_XP"])
					GameTooltip:Show()
				end)

				PlayerTalentFramePVPTalents.XPBar:HookScript("OnLeave", function()
					GameTooltip:Hide()
				end)

				isHonorBarHooked = true
			end
		end)

		ReputationDetailMainScreenCheckBox:SetScript("OnClick", function(self)
			if self:GetChecked() then
				PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
				SetWatchedFactionIndex(GetSelectedFaction())
			else
				PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
				SetWatchedFactionIndex(0)
			end

			UpdateXPBar()
		end)

		SetXPBarStyle(config.width)

		if BARS:IsRestricted() then
			BARS:ActionBarController_AddWidget(bar, "XP_BAR")
		else
			local point = config.point

			bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E:CreateMover(bar)
			E:SetStatusBarSkin(cover, "HORIZONTAL-M")
		end

		isInit = true
	end
end

function BARS.UpdateXPBar()
	if isInit then
		local config = BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar

		SetXPBarStyle(config.width)
		E:UpdateMoverSize(bar)
	end
end
