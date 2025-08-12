local api = require("api")
local settings = api.GetSettings("raidstats")

-- First up is the addon definition!
-- This information is shown in the Addon Manager.
-- You also specify "unload" which is the function called when unloading your addon.
local ep_addon = {
  name = "Raid Stats",
  author = "Delarme",
  desc = "Shows top raid stats",
  version = "0.5.2"
}
local debug = false

local CLASS_BATTLERAGE = 1
local CLASS_WITCHCRAFT = 2
local CLASS_DEFENSE = 3
local CLASS_AURAMANCY = 4
local CLASS_OCCULTISM = 5
local CLASS_ARCHER = 6
local CLASS_MAGE = 7
local CLASS_SHADOWPLAY = 8
local CLASS_SONGCRAFT = 9
local CLASS_VITALISM = 10


local advStatsWnd
local raidStatsWnd

local height = 20
local heightoffset = 30

local labels = {
	"Melee Attack",
	"Ranged Attack",
	"Magic Attack",
	"Healing Power",
	"Melee Health",
	"Ranged Health",
	"Magic Health"
}

local advStatsWndo

local function ReduceAgility(stat, amount)
	stat.ranged_critical_rate = stat.ranged_critical_rate - (0.11 * (amount / 8) )
	stat.melee_critical_rate = stat.melee_critical_rate - (0.11 * (amount / 4) )
	stat.rangeddpsmod = stat.rangeddpsmod - (0.2 * amount)
end


local BuffModificationFunctions = {}

BuffModificationFunctions[11468] = function (stat, buff)
	stat.hasseaknight = true
end
BuffModificationFunctions[835] = function (stat, buff)
	stat.hasode = true
end
BuffModificationFunctions[13783] = function (stat, buff)
	stat.hasode = true
end
BuffModificationFunctions[15031] = function (stat, buff)
	stat.rhythmstacks = buff.stack
end
BuffModificationFunctions[495] = function (stat, buff)
		--zeal buff
		stat.heal_critical_rate = stat.heal_critical_rate - 5
		stat.heal_critical_bonus = stat.heal_critical_bonus - 75

		stat.melee_critical_rate = stat.melee_critical_rate - 5
		stat.melee_critical_bonus = stat.melee_critical_bonus - 75

		stat.ranged_critical_rate = stat.ranged_critical_rate - 5
		stat.ranged_critical_bonus = stat.ranged_critical_bonus - 75

		stat.spell_critical_rate = stat.spell_critical_rate - 5
		stat.spell_critical_bonus = stat.spell_critical_bonus - 75
end
BuffModificationFunctions[7689] = function (stat, buff)
	stat.greyhonorpot = true
end
BuffModificationFunctions[9000056] = function (stat, buff)
	stat.greyhonorpot = true
end
BuffModificationFunctions[900061] = function (stat, buff)
	stat.greyhonorpot = true
end
BuffModificationFunctions[7688] = function (stat, buff)
	stat.pinkhonorpot = true
end
BuffModificationFunctions[9000055] = function (stat, buff)
	stat.pinkhonorpot = true
end
BuffModificationFunctions[900060] = function (stat, buff)
	stat.pinkhonorpot = true
end
BuffModificationFunctions[11344] = function (stat, buff)
	stat.deliriumstacks = buff.stack
end
BuffModificationFunctions[7651] = function (stat, buff)
	--battle focus
	stat.melee_critical_bonus = stat.melee_critical_bonus - 20
end
BuffModificationFunctions[182] = function (stat, buff)
	stat.hasfrenzy = true
end
BuffModificationFunctions[143] = function (stat, buff)
	stat.meleedpsmod = stat.meleedpsmod + (-30 * buff.stack)
	stat.spelldpsmod = stat.spelldpsmod + (-30 * buff.stack)
end
BuffModificationFunctions[21433] = function (stat, buff)
	stat.grandperformance = true
end
BuffModificationFunctions[7663] = function (stat, buff)
	stat.skilldmgbuff = stat.skilldmgbuff + 18 + ((5 - math.ceil((buff.timeLeft + 200) / 1000)) * 2)
end
BuffModificationFunctions[667] = function (stat, buff)
	stat.skilldmgbuff = stat.skilldmgbuff + 16 + ((5 - math.ceil((buff.timeLeft + 200) / 1000)) * 2)
end
BuffModificationFunctions[2196] = function (stat, buff)
	stat.skilldmgbuff = stat.skilldmgbuff + 16 + ((5 - math.ceil((buff.timeLeft + 200) / 1000)) * 2)
end
BuffModificationFunctions[15103] = function (stat, buff)
	stat.skilldmgbuff = stat.skilldmgbuff + 2
end
BuffModificationFunctions[8226] = function (stat, buff)
	--name = "Equip Shield",
	--        description = "Increases Physical Defense and Magic Defense |nc;+200|r.\Increases max Health and Mana |nc;+350|r.",

end
BuffModificationFunctions[6423] = function (stat, buff)
	-- name = "Epic Cloth Armor",
end
BuffModificationFunctions[714] = function (stat, buff)
	-- name = "Complete Cloth Set",
end
BuffModificationFunctions[9000001] = function (stat, buff)
	-- name = "Daru Blessing",
end
BuffModificationFunctions[6605] = function (stat, buff)
	-- name = "General",
end
BuffModificationFunctions[15784] = function (stat, buff)
	-- name = "Eanna's Energy",
end
BuffModificationFunctions[16547] = function (stat, buff)
	-- name = "Amarendra IV's Blessing",
end
BuffModificationFunctions[13779] = function (stat, buff)
	-- name = "Freerunner r2", --agi 180
	ReduceAgility(stat, 180)
end
BuffModificationFunctions[13780] = function (stat, buff)
	-- name = "Freerunner r3", --agi 200
	ReduceAgility(stat, 200)
end
BuffModificationFunctions[15223] = function (stat, buff)
	-- name = "Freerunner rX", --agi 220
	ReduceAgility(stat, 220)
end
BuffModificationFunctions[13781] = function (stat, buff)
	-- name = "Freerunner r4", --agi 220
	ReduceAgility(stat, 220)
end
BuffModificationFunctions[340] = function (stat, buff)
	-- name = "Freerunner r1", --agi 160
	ReduceAgility(stat, 160)
end

local function Sub(tablea, tableb)
	local outtable = {}
	for key,_ in pairs(tablea) do
		--api.Log:Info(key)
		if tableb[key] ~= nil then
			outtable[key] = tablea[key] - tableb[key]
		end
	end
	return tablea
end

local function GetBuffs(unit)
	local buffCount = api.Unit:UnitBuffCount(unit)
	local bufftable = {}
	for i = 0, buffCount do
		local buff = api.Unit:UnitBuff(unit, i)
		if buff ~= nil then
			bufftable[buff.buff_id] = buff
			buff.data = api.Ability:GetBuffTooltip(buff.buff_id, 1)
			--api.File:Write("buffids/buff" .. tostring(buff.buff_id) .. ".txt", buff)
		end
	end

end

local function ComputeEffectiveStat(dps, critrate, critbonus, statbonus, acc)
	local critrateper = critrate / 100
	local critbonusper = critbonus / 100
	local statbonus = 1 + (statbonus / 100)
	local accper = acc / 100
	return dps * ( 1 + (critrateper * critbonusper)) * statbonus * accper
end

local function GetData(unit)
	
	
	local charInfoStat = api.Unit:UnitInfo(unit)

	local unitid = api.Unit:GetUnitId(unit)
	
	local unitinfo = api.Unit:GetUnitInfoById(unitid)
	local maxhp = unitinfo.max_hp
	
	local hassongcraft = false
	local hasbattlerage = false
	local hasshadowplay = false
	--battlerage 1
	--vitalism 4
	--songcraft 8
	--shadowplay 9

	for i = 1, 3 do
		--api.Log:Info(unitinfo.class[tostring(i)])
		if unitinfo.class[tostring(i)] == CLASS_SONGCRAFT then
			hassongcraft = true
		end
		if unitinfo.class[tostring(i)] == CLASS_BATTLERAGE then
			hasbattlerage = true
		end
		if unitinfo.class[tostring(i)] == CLASS_SHADOWPLAY then
			hasshadowplay = true
		end
	end
	--api.Log:Info(tostring(hassongcraft))
	--api.File:Write("charinfomod.txt", charInfoStat)

	local buffCount = api.Unit:UnitBuffCount(unit) or 0

	
	--get debuffs later
	--DecreasesDefense 4679 10 stack max -10% each stack

	-- 180 agi = 15.5 range crit rate from 13.1
	-- 24.4 -> 29.4 melee crit rate different scaling?
	-- 180/3650
	local stat = {}
	stat.haszeal = false
	stat.hasode = false
	stat.rhythmstacks = 0
	stat.deliriumstacks = 0
	stat.hasbattlefocus = false
	stat.hasfrenzy = false
	stat.increaseallattacksstacks = 0
	stat.decreasesdefensestacks = 0

	stat.greyhonorpot = false
	stat.pinkhonorpot = false
	stat.hasseaknight = false
	stat.grandperformance = false
	stat.skilldmgbuff = 0

	stat.healdpsmod = 0
	stat.spelldpsmod = 0
	stat.meleedpsmod = 0
	stat.rangeddpsmod = 0
	stat.skilldmgbuff = 0

	stat.heal_dps				= charInfoStat.heal_dps
	stat.heal_critical_rate		= charInfoStat.heal_critical_rate
	stat.heal_critical_bonus	= charInfoStat.heal_critical_bonus
	stat.heal_mul				= charInfoStat.heal_mul

	stat.melee_dps				= charInfoStat.melee_dps
	stat.melee_critical_rate	= charInfoStat.melee_critical_rate
	stat.melee_critical_bonus	= charInfoStat.melee_critical_bonus
	stat.melee_damage_mul		= charInfoStat.melee_damage_mul
	stat.melee_success_rate		= charInfoStat.melee_success_rate

	stat.ranged_dps				= charInfoStat.ranged_dps
	stat.ranged_critical_rate	= charInfoStat.ranged_critical_rate
	stat.ranged_critical_bonus	= charInfoStat.ranged_critical_bonus
	stat.ranged_damage_mul		= charInfoStat.ranged_damage_mul
	stat.ranged_success_rate	= charInfoStat.ranged_success_rate

	stat.spell_dps				= charInfoStat.spell_dps
	stat.spell_critical_rate	= charInfoStat.spell_critical_rate
	stat.spell_critical_bonus	= charInfoStat.spell_critical_bonus
	stat.spell_damage_mul		= charInfoStat.spell_damage_mul
	stat.spell_success_rate		= charInfoStat.spell_success_rate

	local effectiveHealingPower = ComputeEffectiveStat(stat.heal_dps, stat.heal_critical_rate, stat.heal_critical_bonus, stat.heal_mul, 100)

	local effectivemeleeattack = ComputeEffectiveStat(stat.melee_dps, stat.melee_critical_rate, stat.melee_critical_bonus, stat.melee_damage_mul, stat.melee_success_rate)

	local effectiverangedattack = ComputeEffectiveStat(stat.ranged_dps, stat.ranged_critical_rate, stat.ranged_critical_bonus, stat.ranged_damage_mul, stat.ranged_success_rate)

	local effectivemagicattack = ComputeEffectiveStat(stat.spell_dps, stat.spell_critical_rate, stat.spell_critical_bonus, stat.spell_damage_mul, stat.spell_success_rate)
	


    for i = 1, buffCount  do
		local buff = api.Unit:UnitBuff(unit, i)
		if (BuffModificationFunctions[buff.buff_id] ~= nil) then
			BuffModificationFunctions[buff.buff_id](stat, buff)
		else
			if debug then
				api.Log:Info(buff)
			end
		end
	end


	--if stat.skilldmgbuff > 0 then
	stat.melee_damage_mul = stat.melee_damage_mul - stat.skilldmgbuff
	stat.ranged_damage_mul = stat.ranged_damage_mul - stat.skilldmgbuff
	stat.spell_damage_mul = stat.spell_damage_mul - stat.skilldmgbuff
	--end

	if hasbattlerage then
		melee_critical_bonus = stat.melee_critical_bonus + (20 * (20 / 37.5)) --normalize battle focus

		stat.melee_damage_mul = stat.melee_damage_mul + (2 * (5 - stat.deliriumstacks))
		stat.melee_critical_bonus = stat.melee_critical_bonus + (5 * (5 - stat.deliriumstacks))
	end
	
	if hassongcraft then
	
		-- get belt and count zeal gems

		-- IF HAS ZEAL PASSIVE

		local zealgems = 0


		local gems = api.Equipment:GetEquippedSkillsetLunagems(unit)
		for i = 1, #gems do
			if gems[i] == 38181 then
				zealgems = zealgems + 1
			end
		end
		
		-- compute normalized zeal rate
		local zealuptime = 6 + (0.7 * zealgems)
		local critinc = (zealuptime / 12 ) * 5
		local bonusinc = (zealuptime / 12 ) * 75
		stat.heal_critical_rate = stat.heal_critical_rate + critinc
		stat.heal_critical_bonus = stat.heal_critical_bonus + bonusinc

		stat.melee_critical_rate = stat.melee_critical_rate + critinc
		stat.melee_critical_bonus = stat.melee_critical_bonus + bonusinc

		stat.ranged_critical_rate = stat.ranged_critical_rate + critinc
		stat.ranged_critical_bonus = stat.ranged_critical_bonus + bonusinc

		stat.spell_critical_rate = stat.spell_critical_rate  + critinc
		stat.spell_critical_bonus = stat.spell_critical_bonus + bonusinc

		-- IF RHYTHM LEARNED (assumed)
		stat.healdpsmod = stat.healdpsmod + (7 * (15 - stat.rhythmstacks))
		stat.spelldpsmod = stat.spelldpsmod + (7 * (15 - stat.rhythmstacks))
	end

	if stat.hasode == false then
		if stat.hasseaknight then
			stat.healdpsmod = stat.healdpsmod + 105
		else
			stat.healdpsmod = stat.healdpsmod + 80
		end
	else
		if stat.grandperformance == true then
			if stat.hasseaknight then
				stat.healdpsmod = stat.healdpsmod - 136.5
				stat.healdpsmod = stat.healdpsmod + 105
			else
				stat.healdpsmod = stat.healdpsmod - 104
				stat.healdpsmod = stat.healdpsmod + 80
			end
		end
	end

	if stat.greyhonorpot then
		stat.heal_dps = stat.heal_dps + (stat.healdpsmod * 1.15)
		stat.spell_dps = stat.spell_dps + (stat.spelldpsmod * 1.15)
	else
		stat.heal_dps = stat.heal_dps + stat.healdpsmod
		stat.spell_dps = stat.spell_dps + stat.spelldpsmod
	end

	if stat.pinkhonorpot then
		stat.melee_dps = stat.melee_dps + (stat.meleedpsmod * 1.15)
		stat.ranged_dps = stat.ranged_dps + (stat.rangeddpsmod * 1.15)
	else
		stat.melee_dps = stat.melee_dps + stat.meleedpsmod
		stat.ranged_dps = stat.ranged_dps + stat.rangeddpsmod
	end
	
	local normalizedHealingPower = ComputeEffectiveStat(stat.heal_dps, stat.heal_critical_rate, stat.heal_critical_bonus,  stat.heal_mul, 100)

	local normalizedmeleeattack = ComputeEffectiveStat(stat.melee_dps, stat.melee_critical_rate, stat.melee_critical_bonus, stat.melee_damage_mul, stat.melee_success_rate)

	local normalizedrangedattack = ComputeEffectiveStat(stat.ranged_dps, stat.ranged_critical_rate, stat.ranged_critical_bonus, stat.ranged_damage_mul, stat.ranged_success_rate)

	local normalizedmagicattack = ComputeEffectiveStat(stat.spell_dps, stat.spell_critical_rate, stat.spell_critical_bonus, stat.spell_damage_mul, stat.spell_success_rate)

	local magicmul = 100 / (100 + charInfoStat.incoming_spell_damage_mul) 
	local meleemul = 100 / (100 + charInfoStat.incoming_melee_damage_mul ) 
	local rangedmul = 100 / (100 + charInfoStat.incoming_ranged_damage_mul )
	-- div 0 alert or worse ;3 Thanks Crawling!
	if (charInfoStat.magic_resist_percentage > 99.95) then
		charInfoStat.magic_resist_percentage = 99.95
	end
	if (charInfoStat.armor_percentage > 99.95) then
		charInfoStat.armor_percentage = 99.95
	end
	local armorres = 100 / (100 - charInfoStat.armor_percentage)
	local magicres = (100 / (100 - charInfoStat.magic_resist_percentage))
	local toughreduc = charInfoStat.battle_resist / (8000 + charInfoStat.battle_resist)
	local toughmul = (1 / (1 - toughreduc))
	

	local meleehp = maxhp * armorres * toughmul * meleemul
	local rangedhp = maxhp * armorres * toughmul * rangedmul
	local magichp = maxhp * magicmul * magicres * toughmul 

	local data = {}
	data[1] = effectivemeleeattack
	data[2] = effectiverangedattack
	data[3] = effectivemagicattack
	data[4] = effectiveHealingPower
	data[5] = meleehp
	data[6] = rangedhp
	data[7] = magichp

	data[8] = normalizedmeleeattack
	data[9] = normalizedrangedattack
	data[10] = normalizedmagicattack
	data[11] = normalizedHealingPower
	data[12] = meleehp
	data[13] = rangedhp
	data[14] = magichp

	return data

end

local function GetUnitId(unit)
	return api.Unit:GetUnitId(unit)

end

local function GetUnitNameById(unitid)
	return api.Unit:GetUnitNameById(unitid)
end

local myName = ""

local function Fetch(unit, type)
	local gotunitid, unitid = pcall(GetUnitId, unit)
	--api.Log:Info(unit)
	--api.Log:Info(tostring(gotunitid))
	if gotunitid == false then
		return false, "no unit id"
	end
	if unitid == nil then
		return false, "unit id is nil"
	end
	--api.Log:Info(unitid)
	--local name = GetUnitNameById(unitid)
	
	local gotunitname, unitname = pcall(GetUnitNameById, unitid)
	--api.Log:Info(tostring(unitname))
	if gotunitname == false then
		--api.Log:Info("Unit too far away")
		return false, unitname
	end
	if unitname == nil then
		return false, "could not get unit name"
	end
	if unit ~= "player" then
		--api.Log:Info(unit)
		if unitname == myName then
			return false, "self, skipping"
		end
	end
	--api.Log:Info(unitname)
	local success, statdata = pcall(GetData, unit)
	if success == false then
		api.Log:Info(statdata)
		return false
	end
	--local statdata = GetData(unit)
	return true, {["name"] = unitname, ["data"] = statdata[type]}
end



local function GetRaidData(type)

	--api.Log:Info(type)

	out = {}

	local res, myself = Fetch("player", type)
	if res ~= false then
		myName = myself.name
		out[myself.name] = myself.data
	end

	
	for i = 1, 50 do
		local unit = "team" .. i
		
		local result, output = Fetch(unit, type)
		if result ~= false then
			--api.Log:Info(unit .. " " .. output.name)
			out[output.name] = output.data
		else
			--api.Log:Info(output)
		end
	end
	return out
end

-- The Load Function is called as soon as the game loads its UI. Use it to initialize anything you need!
local function Load() 
  
	--eapi.Log:Info("Loading ep...")
	info = ADDON:GetContent(UIC.CHARACTER_INFO)
	
	--raidStatsWnd = CreateRaidStatsWindow()

	raidStatsWnd = require("raidstats/stats_raid_view")
	raidStatsWnd:SetGetDataDelegate(GetRaidData)
	--api.Log:Info(raidStatsWnd)
	data = GetData("player")
	
	advStatsWndo = api.Interface:CreateWindow("advStatsWndo", "Effective Stats", 300, 200)
	advStatsWndo.child = {}
	advStatsWndo:Show(false)
	
	for i = 1, 7 do 
		--api.Log:Info(data[i])
		k = i + 7
		advStatsWndo.child[i] = api.Interface:CreateWidget("label", "text" .. i, advStatsWndo)
		advStatsWndo.child[i]:AddAnchor("TOPLEFT", 12, height * i +heightoffset)
		advStatsWndo.child[i]:SetExtent(255, height)
		advStatsWndo.child[i]:SetText(labels[i])
		advStatsWndo.child[i].style:SetColor(0, 0, 0, 1)
		advStatsWndo.child[i].style:SetAlign(ALIGN.LEFT)
		advStatsWndo.child[i]:Show(true)

		advStatsWndo.child[k] = api.Interface:CreateWidget("label", "textstat" .. i, advStatsWndo)
		advStatsWndo.child[k]:AddAnchor("TOPLEFT", 200, height * i +heightoffset)
		advStatsWndo.child[k]:SetExtent(255, height)
		advStatsWndo.child[k]:SetText(string.format("%.0f", data[i]))
		advStatsWndo.child[k].style:SetColor(0, 0, 0, 1)
		advStatsWndo.child[k].style:SetAlign(ALIGN.LEFT)
		advStatsWndo.child[k]:Show(true)
	end
end




-- Unload is called when addons are reloaded.
-- Here you want to destroy your windows and do other tasks you find useful.
local function Unload()

	if advStatsWndo ~= nil then
		advStatsWndo:Show(false)
		advStatsWndo = nil
	end
	if raidStatsWnd ~= nil then
		raidStatsWnd:Close()
		raidStatsWnd = nil
	end
end

if api._Addons == nil then
	api._Addons = {}
end
advstatsapi = {}
advstatsapi.GetData = GetData
api._Addons.AdvStats = advstatsapi

-- Here we make sure to bind the functions we defined to our addon. This is how the game knows what function to use!
ep_addon.OnLoad = Load
ep_addon.OnUnload = Unload
--X2Item:GetItemIconSet(itemType, itemGrade)

return ep_addon
