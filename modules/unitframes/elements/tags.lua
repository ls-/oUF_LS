local _, ns = ...
local E, C, M, L, P, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.oUF

--Lua
local _G = getfenv(0)
local s_format = _G.string.format

-- Blizz
local ALTERNATE_POWER_INDEX = _G.ALTERNATE_POWER_INDEX or 10
local LE_REALM_RELATION_VIRTUAL = _G.LE_REALM_RELATION_VIRTUAL
local GetPVPTimer = _G.GetPVPTimer
local IsPVPTimerRunning = _G.IsPVPTimerRunning
local IsResting = _G.IsResting
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitAlternatePowerInfo = _G.UnitAlternatePowerInfo
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitCanAssist = _G.UnitCanAssist
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitCreatureType = _G.UnitCreatureType
local UnitDebuff = _G.UnitDebuff
local UnitEffectiveLevel = _G.UnitEffectiveLevel
local UnitGetTotalAbsorbs = _G.UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = _G.UnitGetTotalHealAbsorbs
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitInParty = _G.UnitInParty
local UnitInPhase = _G.UnitInPhase
local UnitInRaid = _G.UnitInRaid
local UnitIsBattlePetCompanion = _G.UnitIsBattlePetCompanion
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsQuestBoss = _G.UnitIsQuestBoss
local UnitIsWarModePhased = _G.UnitIsWarModePhased
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType
local UnitReaction = _G.UnitReaction
local UnitRealmRelationship = _G.UnitRealmRelationship

--[[ luacheck: globals
	Hex
]]

-- Mine
local DEBUFF_ICONS = {
	["Curse"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:67:99:1:33|t",
	["Disease"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:1:33:34:66|t",
	["Magic"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:34:66:34:66|t",
	["Poison"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:67:99:34:66|t",
}

local SHEEPABLE_TYPES = {
	["Beast"] = true,
	["Bestia"] = true,
	["Bête"] = true,
	["Fera"] = true,
	["Humanoid"] = true,
	["Humanoide"] = true,
	["Humanoïde"] = true,
	["Umanoide"] = true,
	["Wildtier"] = true,
	["Гуманоид"] = true,
	["Животное"] = true,
	["야수"] = true,
	["인간형"] = true,
	["人型生物"] = true,
	["人形生物"] = true,
	["野兽"] = true,
	["野獸"] = true,
}

------------
-- COLOUR --
------------

oUF.Tags.Events["ls:color:class"] = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:color:class"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		if class then
			return "|c" .. C.db.global.colors.class[class].hex
		end
	end

	return "|cffffffff"
end

oUF.Tags.Events["ls:color:reaction"] = "UNIT_FACTION UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:color:reaction"] = function(unit)
	local reaction = UnitReaction(unit, 'player')

	if reaction then
		return "|c" .. C.db.profile.colors.reaction[reaction].hex
	end

	return "|cffffffff"
end

oUF.Tags.Events["ls:color:difficulty"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["ls:color:difficulty"] = function(unit)
	return "|c" .. E:GetCreatureDifficultyColor(UnitEffectiveLevel(unit)).hex
end

oUF.Tags.Methods["ls:color:power"] = function(unit)
	local type, _, r, g, b = UnitPowerType(unit)
	if not r then
		return "|c" .. C.db.profile.colors.power[type].hex
	else
		if r > 1 or g > 1 or b > 1 then
			r, g, b = r / 255, g / 255, b / 255
		end

		return Hex(r, g, b)
	end
end

oUF.Tags.Methods["ls:color:altpower"] = function()
	return "|c" .. C.db.profile.colors.power.ALT_POWER.hex
end

oUF.Tags.Methods["ls:color:absorb-damage"] = function()
	return "|c" .. C.db.profile.colors.prediction.damage_absorb.hex
end

oUF.Tags.Methods["ls:color:absorb-heal"] = function()
	return "|c" .. C.db.profile.colors.prediction.heal_absorb.hex
end

------------
-- HEALTH --
------------

oUF.Tags.Events["ls:health:cur"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
oUF.Tags.Methods["ls:health:cur"] = function(unit)
	if not UnitIsConnected(unit) then
		return L["OFFLINE"]
	elseif UnitIsDeadOrGhost(unit) then
		return L["DEAD"]
	else
		return E:FormatNumber(UnitHealth(unit))
	end
end

oUF.Tags.Events["ls:health:perc"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
oUF.Tags.Methods["ls:health:perc"] = function(unit)
	if not UnitIsConnected(unit) then
		return L["OFFLINE"]
	elseif UnitIsDeadOrGhost(unit) then
		return L["DEAD"]
	else
		return s_format("%.1f%%", E:NumberToPerc(UnitHealth(unit), UnitHealthMax(unit)))
	end
end

oUF.Tags.Events["ls:health:cur-perc"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
oUF.Tags.Methods["ls:health:cur-perc"] = function(unit)
	if not UnitIsConnected(unit) then
		return L["OFFLINE"]
	elseif UnitIsDeadOrGhost(unit) then
		return L["DEAD"]
	else
		local cur, max = UnitHealth(unit), UnitHealthMax(unit)
		if cur == max then
			return E:FormatNumber(cur)
		else
			return s_format("%s - %.1f%%", E:FormatNumber(cur), E:NumberToPerc(cur, max))
		end
	end
end

oUF.Tags.Events["ls:health:deficit"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
oUF.Tags.Methods["ls:health:deficit"] = function(unit)
	if not UnitIsConnected(unit) then
		return L["OFFLINE"]
	elseif UnitIsDeadOrGhost(unit) then
		return L["DEAD"]
	else
		local cur, max = UnitHealth(unit), UnitHealthMax(unit)
		if max and cur ~= max then
			return s_format("-%s", E:FormatNumber(max - cur))
		end
	end

	return ""
end

-----------
-- POWER --
-----------

oUF.Tags.Events["ls:power:cur"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:cur"] = function(unit)
	if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
		local type = UnitPowerType(unit)
		local max = UnitPowerMax(unit, type)
		if max and max ~= 0 then
			return E:FormatNumber(UnitPower(unit, type))
		end
	end

	return ""
end

oUF.Tags.Events["ls:power:max"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:max"] = function(unit)
	if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
		local type = UnitPowerType(unit)
		local max = UnitPowerMax(unit, type)
		if max and max ~= 0 then
			return E:FormatNumber(max)
		end
	end

	return ""
end

oUF.Tags.Events["ls:power:perc"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:perc"] = function(unit)
	if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
		local type = UnitPowerType(unit)
		local max = UnitPowerMax(unit, type)
		if max and max ~= 0 then
			return s_format("%.1f%%", E:NumberToPerc(UnitPower(unit, type), max))
		end
	end

	return ""
end

oUF.Tags.Events["ls:power:cur-perc"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:cur-perc"] = function(unit)
	if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
		local type = UnitPowerType(unit)
		local max = UnitPowerMax(unit, type)
		if max and max ~= 0 then
			local cur = UnitPower(unit, type)
			if cur == 0 or cur == max then
				return E:FormatNumber(cur)
			else
				return s_format("%s - %.1f%%", E:FormatNumber(cur), E:NumberToPerc(cur, max))
			end
		end
	end

	return ""
end

oUF.Tags.Events["ls:power:cur-color-perc"] = oUF.Tags.Events["ls:power:cur-perc"]
oUF.Tags.Methods["ls:power:cur-color-perc"] = oUF.Tags.Methods["ls:power:cur-perc"]

oUF.Tags.Events["ls:power:cur-max"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:cur-max"] = function(unit)
	if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
		local type = UnitPowerType(unit)
		local max = UnitPowerMax(unit, type)
		if max and max ~= 0 then
			local cur = UnitPower(unit, type)
			if cur == max or cur == 0 then
				return E:FormatNumber(cur)
			else
				return s_format("%s - %s", E:FormatNumber(cur), E:FormatNumber(max))
			end
		end
	end

	return ""
end

oUF.Tags.Events["ls:power:cur-color-max"] = oUF.Tags.Events["ls:power:cur-max"]
oUF.Tags.Methods["ls:power:cur-color-max"] = oUF.Tags.Methods["ls:power:cur-max"]

oUF.Tags.Events["ls:power:deficit"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:deficit"] = function(unit)
	if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
		local type = UnitPowerType(unit)
		local cur, max = UnitPower(unit, type), UnitPowerMax(unit, type)
		if max and cur ~= max then
			return s_format("-%s", E:FormatNumber(max - cur))
		end
	end

	return ""
end

---------------
-- ALT POWER --
---------------

oUF.Tags.Events["ls:altpower:cur"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:cur"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		return E:FormatNumber(UnitPower(unit, ALTERNATE_POWER_INDEX))
	end

	return ""
end

oUF.Tags.Events["ls:altpower:max"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:max"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		return E:FormatNumber(UnitPowerMax(unit, ALTERNATE_POWER_INDEX))
	end

	return ""
end

oUF.Tags.Events["ls:altpower:perc"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:perc"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		return s_format("%.1f%%", E:NumberToPerc(UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)))
	end

	return ""
end

oUF.Tags.Events["ls:altpower:cur-perc"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:cur-perc"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		local cur, max = UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
		if cur == max then
			return E:FormatNumber(cur)
		else
			return s_format("%s - %.1f%%", E:FormatNumber(cur), E:NumberToPerc(cur, max))
		end
	end

	return ""
end

oUF.Tags.Events["ls:altpower:cur-color-perc"] = oUF.Tags.Events["ls:altpower:cur-perc"]
oUF.Tags.Methods["ls:altpower:cur-color-perc"] = oUF.Tags.Methods["ls:altpower:cur-perc"]

oUF.Tags.Events["ls:altpower:cur-max"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:cur-max"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		local cur, max = UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
		if cur == max then
			return E:FormatNumber(cur)
		else
			return s_format("%s - %s", E:FormatNumber(cur), E:FormatNumber(max))
		end
	end

	return ""
end

oUF.Tags.Events["ls:altpower:cur-color-max"] = oUF.Tags.Events["ls:altpower:cur-max"]
oUF.Tags.Methods["ls:altpower:cur-color-max"] = oUF.Tags.Methods["ls:altpower:cur-max"]

----------
-- NAME --
----------

oUF.Tags.Events["ls:name"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name"] = function(unit, r)
	return UnitName(r or unit) or ""
end

oUF.Tags.Events["ls:name:5"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name:5"] = function(unit, r)
	local name = UnitName(r or unit) or ""
	return name ~= "" and E:TruncateString(name, 5) or name
end

oUF.Tags.Events["ls:name:10"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name:10"] = function(unit, r)
	local name = UnitName(r or unit) or ""
	return name ~= "" and E:TruncateString(name, 10) or name
end

oUF.Tags.Events["ls:name:15"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name:15"] = function(unit, r)
	local name = UnitName(r or unit) or ""
	return name ~= "" and E:TruncateString(name, 15) or name
end

oUF.Tags.Events["ls:name:20"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name:20"] = function(unit, r)
	local name = UnitName(r or unit) or ""
	return name ~= "" and E:TruncateString(name, 20) or name
end

oUF.Tags.Events["ls:server"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:server"] = function(unit, r)
	local _, realm = UnitName(r or unit)
	if realm and realm ~= "" then
		local relationship = UnitRealmRelationship(r or unit)
		if relationship ~= LE_REALM_RELATION_VIRTUAL then
			return L["FOREIGN_SERVER_LABEL"]
		end
	end

	return ""
end

-----------
-- CLASS --
-----------

oUF.Tags.Events["ls:npc:type"] = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:npc:type"] = function(unit)
	local classification = UnitClassification(unit)
	if classification == "rare" then
		return "R"
	elseif classification == "rareelite" then
		return "R+"
	elseif classification == "elite" then
		return "+"
	elseif classification == "worldboss" then
		return "B"
	elseif classification == "minus" then
		return "-"
	end

	return ""
end

oUF.Tags.Events["ls:player:class"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["ls:player:class"] = function(unit)
	if UnitIsPlayer(unit) then
		local class = UnitClass(unit)
		if class then
			return class
		end
	end

	return ""
end

------------
-- ABSORB --
------------

oUF.Tags.Events["ls:absorb:heal"] = "UNIT_HEAL_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Methods["ls:absorb:heal"] = function(unit)
	local absorb = UnitGetTotalHealAbsorbs(unit) or 0
	return absorb > 0 and E:FormatNumber(absorb) or " "
end

oUF.Tags.Events["ls:absorb:damage"] = "UNIT_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Methods["ls:absorb:damage"] = function(unit)
	local absorb = UnitGetTotalAbsorbs(unit) or 0
	return absorb > 0 and E:FormatNumber(absorb) or " "
end

-----------
-- LEVEL --
-----------

oUF.Tags.Events["ls:level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["ls:level"] = function(unit)
	local level

	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
	else
		level = UnitLevel(unit)
	end

	return level > 0 and level or "??"
end

oUF.Tags.Events["ls:level:effective"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["ls:level:effective"] = function(unit)
	local level

	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
	else
		level = UnitEffectiveLevel(unit)
	end

	return level > 0 and level or "??"
end

----------
-- MISC --
----------

oUF.Tags.Methods["nl"] = function() return "\n" end

oUF.Tags.Events["ls:debuffs"] = "UNIT_AURA"
oUF.Tags.Methods["ls:debuffs"] = function(unit)
	local types = E:GetDispelTypes()
	if not types or not UnitCanAssist("player", unit) then
		return ""
	end

	local hasDebuff = {Curse = false, Disease = false, Magic = false, Poison = false}
	local status = ""

	for i = 1, 40 do
		local name, _, _, type = UnitDebuff(unit, i, "RAID")
		if not name then
			break
		end

		if types[type] and not hasDebuff[type] then
			status = status .. DEBUFF_ICONS[type]
			hasDebuff[type] = true
		end
	end

	return status
end

oUF.Tags.Events["ls:classicon"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["ls:classicon"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		if class then
			return M.textures.inlineicons[class]:format(0, 0)
		end
	end

	return ""
end

oUF.Tags.Events["ls:questicon"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["ls:questicon"] = function(unit)
	if UnitIsQuestBoss(unit) then
		return M.textures.inlineicons["QUEST"]:format(0, 0)
	end

	return ""
end

oUF.Tags.Events["ls:sheepicon"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["ls:sheepicon"] = function(unit)
	if UnitCanAttack("player", unit)
		and (UnitIsPlayer(unit) or SHEEPABLE_TYPES[UnitCreatureType(unit)])
		and (E.PLAYER_CLASS == "MAGE" or E.PLAYER_CLASS == "SHAMAN") then
		return M.textures.inlineicons["SHEEP"]:format(0, 0)
	end

	return ""
end

oUF.Tags.Events["ls:phaseicon"] = "UNIT_PHASE"
oUF.Tags.Methods["ls:phaseicon"] = function(unit)
	if (not UnitInPhase(unit) or UnitIsWarModePhased(unit)) and UnitIsPlayer(unit) and UnitIsConnected(unit) then
		if UnitIsWarModePhased(unit) then
			return M.textures.inlineicons["PHASE_WM"]:format(0, 0)
		else
			return M.textures.inlineicons["PHASE"]:format(0, 0)
		end
	end

	return ""
end

oUF.Tags.Events["ls:leadericon"] = "PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["ls:leadericon"] = function(unit)
	if (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit) then
		return M.textures.inlineicons["LEADER"]:format(0, 0)
	end

	return ""
end

oUF.Tags.Events["ls:lfdroleicon"] = "GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["ls:lfdroleicon"] = function(unit)
	local role = UnitGroupRolesAssigned(unit)
	if role and role ~= "NONE" then
		return M.textures.inlineicons[role]:format(0, 0)
	end

	return ""
end

oUF.Tags.Events["ls:combatresticon"] = "PLAYER_UPDATE_RESTING PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED"
oUF.Tags.Methods["ls:combatresticon"] = function()
	if UnitAffectingCombat("player") then
		return M.textures.inlineicons["COMBAT"]:format(0, 0)
	elseif IsResting() then
		return M.textures.inlineicons["RESTING"]:format(0, 0)
	end

	return ""
end

oUF.Tags.SharedEvents["PLAYER_REGEN_DISABLED"] = true
oUF.Tags.SharedEvents["PLAYER_REGEN_ENABLED"] = true
oUF.Tags.Methods["ls:pvptimer"] = function()
	if IsPVPTimerRunning() then
		local remain = GetPVPTimer() / 1000
		if remain >= 1 then
			local time1, time2, format

			if remain >= 60 then
				time1, time2, format = E:SecondsToTime(remain, "x:xx")
			else
				time1, time2, format = E:SecondsToTime(remain)
			end

			return format:format(time1, time2)
		end
	end
end
