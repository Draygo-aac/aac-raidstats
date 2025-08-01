local api = require("api")
local settings = api.GetSettings("raidstats")

-- First up is the addon definition!
-- This information is shown in the Addon Manager.
-- You also specify "unload" which is the function called when unloading your addon.
local ep_addon = {
  name = "Raid Stats",
  author = "Delarme",
  desc = "Shows top raid stats",
  version = "0.5.1"
}



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

function ComputeEffectiveStat(dps, critrate, critbonus, statbonus, acc)
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
	--battlerage 1
	--vitalism 4
	--songcraft 8
	--shadowplay 9

	for i = 1, 3 do
		--api.Log:Info(unitinfo.class[tostring(i)])
		if unitinfo.class[tostring(i)] == 9 then
			hassongcraft = true
		end
		if unitinfo.class[tostring(i)] == 1 then
			hasbattlerage = true
		end
	end
	--api.Log:Info(tostring(hassongcraft))
	--api.File:Write("charinfomod.txt", charInfoStat)
	local haszeal = false
	local hasode = false
	local rhythmstacks = 0
	local deliriumstacks = 0
	local hasbattlefocus = false
	local hasfrenzy = false
	local increaseallattacksstacks = 0
	local decreasesdefensestacks = 0

	local greyhonorpot = false
	local pinkhonorpot = false
	local hasseaknight = false
	local grandperformance = false
	local buffCount = api.Unit:UnitBuffCount(unit) or 0
	
    for i = 1, buffCount  do
		local buff = api.Unit:UnitBuff(unit, i)
		if buff.buff_id == 11467 then
			hasseaknight = true
		end
		if buff.buff_id == 835 then
			hasode = true
		end
		if buff.buff_id == 13783 then
			hasode = true
		end
		if buff.buff_id == 15031 then
			rhythmstacks = buff.stack
		end
		if buff.buff_id == 495 then
			haszeal = true
		end
		if buff.buff_id == 7689 or buff.buff_id == 9000056 or buff.buff_id == 900061 then
			greyhonorpot = true
		end
		--melee and ranged
		if buff.buff_id == 7688 or buff.buff_id == 9000055 or buff.buff_id == 900060 then
			pinkhonorpot = true
		end

		if buff.buff_id == 11344 then
			deliriumstacks = buff.stack
			-- 2 melee skill damage
			-- 5 melee crit bonus
		end
		if buff.buff_id == 7651 then
			hasbattlefocus = true
		end
		if buff.buff_id == 182 then
			hasfrenzy = true
		end
		if buff.buff_id == 143 then
			increaseallattacksstacks = buff.stack
		end
		if buff.buff_id == 21433 then
			grandperformance = true
		end
	end
	
	--get debuffs later
	--DecreasesDefense 4679 10 stack max -10% each stack

	-- 180 agi = 15.5 range crit rate from 13.1
	-- 24.4 -> 29.4 melee crit rate different scaling?
	-- 180/3650
	local heal_dps				= charInfoStat.heal_dps
	local heal_critical_rate	= charInfoStat.heal_critical_rate
	local heal_critical_bonus	= charInfoStat.heal_critical_bonus
	local heal_mul				= charInfoStat.heal_mul

	local melee_dps				= charInfoStat.melee_dps
	local melee_critical_rate	= charInfoStat.melee_critical_rate
	local melee_critical_bonus	= charInfoStat.melee_critical_bonus
	local melee_damage_mul		= charInfoStat.melee_damage_mul
	local melee_success_rate	= charInfoStat.melee_success_rate

	local ranged_dps			= charInfoStat.ranged_dps
	local ranged_critical_rate	= charInfoStat.ranged_critical_rate
	local ranged_critical_bonus = charInfoStat.ranged_critical_bonus
	local ranged_damage_mul		= charInfoStat.ranged_damage_mul
	local ranged_success_rate	= charInfoStat.ranged_success_rate

	local spell_dps				= charInfoStat.spell_dps
	local spell_critical_rate	= charInfoStat.spell_critical_rate
	local spell_critical_bonus	= charInfoStat.spell_critical_bonus
	local spell_damage_mul		= charInfoStat.spell_damage_mul
	local spell_success_rate	= charInfoStat.spell_success_rate

	local effectiveHealingPower = ComputeEffectiveStat(heal_dps, heal_critical_rate, heal_critical_bonus,  heal_mul, 100)

	local effectivemeleeattack = ComputeEffectiveStat(melee_dps, melee_critical_rate, melee_critical_bonus, melee_damage_mul, melee_success_rate)

	local effectiverangedattack = ComputeEffectiveStat(ranged_dps, ranged_critical_rate, ranged_critical_bonus, ranged_damage_mul, ranged_success_rate)

	local effectivemagicattack = ComputeEffectiveStat(spell_dps, spell_critical_rate, spell_critical_bonus, spell_damage_mul, spell_success_rate)
	
	local healdpsmod = 0
	local spelldpsmod = 0
	local meleedpsmod = 0
	local rangeddpsmod = 0
	
	if hasbattlerage then
		if hasbattlefocus then
			melee_critical_bonus = melee_critical_bonus - 20
		end
		melee_critical_bonus = melee_critical_bonus + (20 * (20 / 37.5)) --normalize battle focus

		melee_damage_mul = melee_damage_mul + (2 * (5 - deliriumstacks))
		melee_critical_bonus = melee_critical_bonus + (5 * (5 - deliriumstacks))

		meleedpsmod = meleedpsmod + (-30 * increaseallattacksstacks)
		spelldpsmod = spelldpsmod + (-30 * increaseallattacksstacks)
	end
	
	if hassongcraft then
	
		if haszeal then
			heal_critical_rate = heal_critical_rate - 5
			heal_critical_bonus = heal_critical_bonus - 75

			melee_critical_rate = melee_critical_rate - 5
			melee_critical_bonus = melee_critical_bonus - 75

			ranged_critical_rate = ranged_critical_rate - 5
			ranged_critical_bonus = ranged_critical_bonus - 75

			spell_critical_rate = spell_critical_rate - 5
			spell_critical_bonus = spell_critical_bonus - 75
		end
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
		heal_critical_rate = heal_critical_rate + critinc
		heal_critical_bonus = heal_critical_bonus + bonusinc

		melee_critical_rate = melee_critical_rate + critinc
		melee_critical_bonus = melee_critical_bonus + bonusinc

		ranged_critical_rate = ranged_critical_rate + critinc
		ranged_critical_bonus = ranged_critical_bonus + bonusinc

		spell_critical_rate = spell_critical_rate  + critinc
		spell_critical_bonus = spell_critical_bonus + bonusinc

		-- IF RHYTHM LEARNED (assumed)
		healdpsmod = healdpsmod + (7 * (15 - rhythmstacks))
		spelldpsmod = spelldpsmod + (7 * (15 - rhythmstacks))
	end

	if hasode == false then
		if hasseaknight then
			healdpsmod = healdpsmod + 105
		else
			healdpsmod = healdpsmod + 80
		end
	else
		if grandperformance == true then
			if hasseaknight then
				healdpsmod = healdpsmod - 136.5
				healdpsmod = healdpsmod + 105
			else
				healdpsmod = healdpsmod - 104
				healdpsmod = healdpsmod + 80
			end
		end
	end
	
	-- is it possible to get the buff amount for bloody chanty/bulwark ballad?

	if greyhonorpot then
		heal_dps = heal_dps + (healdpsmod * 1.15)
		spell_dps = spell_dps + (spelldpsmod * 1.15)
	else
		heal_dps = heal_dps + healdpsmod
		spell_dps = spell_dps + spelldpsmod
	end

	if pinkhonorpot then
		melee_dps = melee_dps + (meleedpsmod * 1.15)
		ranged_dps = ranged_dps + (rangeddpsmod * 1.15)
	else
		melee_dps = melee_dps + meleedpsmod
		ranged_dps = ranged_dps + rangeddpsmod
	end
	
	local normalizedHealingPower = ComputeEffectiveStat(heal_dps, heal_critical_rate,heal_critical_bonus,  heal_mul, 100)

	local normalizedmeleeattack = ComputeEffectiveStat(melee_dps, melee_critical_rate, melee_critical_bonus, melee_damage_mul, melee_success_rate)

	local normalizedrangedattack = ComputeEffectiveStat(ranged_dps, ranged_critical_rate, ranged_critical_bonus, ranged_damage_mul, ranged_success_rate)

	local normalizedmagicattack = ComputeEffectiveStat(spell_dps, spell_critical_rate, spell_critical_bonus, spell_damage_mul, spell_success_rate)

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

function GetUnitId(unit)
	return api.Unit:GetUnitId(unit)

end

function GetUnitNameById(unitid)
	return api.Unit:GetUnitNameById(unitid)
end

local myName = ""

function Fetch(unit, type)
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
	local statdata = GetData(unit)
	return true, {["name"] = unitname, ["data"] = statdata[type]}
end



function GetRaidData(type)

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
