local function ReduceAgility(stat, amount)
	stat.ranged_critical_rate = stat.ranged_critical_rate - (0.11 * (amount / 8) )
	stat.melee_critical_rate = stat.melee_critical_rate - (0.11 * (amount / 4) )
	stat.rangeddpsmod = stat.rangeddpsmod - (0.2 * amount)
end

local function AdjustDamageReduction(stat, amount)
	stat.incoming_spell_damage_mul	= stat.incoming_spell_damage_mul + amount   
	stat.incoming_melee_damage_mul  = stat.incoming_melee_damage_mul + amount
	stat.incoming_ranged_damage_mul = stat.incoming_ranged_damage_mul + amount
end

local function ReduceIntelligence(stat, amount)
		--mattk 0.2 per point
		--magic crit rate 0.11 per 4
		--ranged crit rate 0.11 per 8
	stat.ranged_critical_rate = stat.ranged_critical_rate - (0.11 * (amount / 8) )
	stat.magic_critical_rate = stat.magic_critical_rate - (0.11 * (amount / 4) )
	stat.magicdpsmod = stat.magicdpsmod - (0.2 * amount)
end

local function ReduceStrength(stat, amount)
		--mattk 0.2 per point
end

local function ReduceStamina(stat, amount)
	-- health 12 per point

end

local function ReduceSpirit(stat, amount)
	--healing power 0.2 per point
	--magic defense 1 per point
	--heal crit rate .11 per 4 points
end

local function AdjustSkillDamage(stat, amount)
	stat.melee_damage_mul = stat.melee_damage_mul + amount
	stat.ranged_damage_mul = stat.ranged_damage_mul + amount
	stat.spell_damage_mul = stat.spell_damage_mul + amount
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
	--battle focus rank 2
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

BuffModificationFunctions[6148] = function (stat, buff)
	-- name = "Blooddrinker"
	AdjustDamageReduction(stat, 21)
end
BuffModificationFunctions[5662] = function (stat, buff)
	-- name = "Monsterous Desire"
	ReduceIntelligence(stat, 75)
end
BuffModificationFunctions[127] = function (stat, buff)
	-- name = "Twart"

end
BuffModificationFunctions[11426] = function (stat, buff)
	-- name = "Workmans haste"

end
BuffModificationFunctions[715] = function (stat, buff)
	-- name = "leather armor"

end
BuffModificationFunctions[716] = function (stat, buff)
	-- name = "leather armor"

end
BuffModificationFunctions[499] = function (stat, buff)
	-- name = "sleep immunity"
	
end
BuffModificationFunctions[8227] = function (stat, buff)
	-- name = "two handed"
	
end
BuffModificationFunctions[6430] = function (stat, buff)
	-- name = "divine armor"
	
end
BuffModificationFunctions[13867] = function (stat, buff)
	-- name = "Health Lift"
	
end
BuffModificationFunctions[674] = function (stat, buff)
	-- name = "Kingdoms physical"
	
end
BuffModificationFunctions[2113] = function (stat, buff)
	-- name = "berserk (honor nodachi)" + 25% skill damage rec damage +70%
	--ReduceIntelligence(stat, 75)
	AdjustDamageReduction(stat, -70)
	AdjustSkillDamage(stat, -25)
end
BuffModificationFunctions[8000500 ] = function (stat, buff)
	-- name = "Powerstone Pet health lift" 

end

BuffModificationFunctions[8000502 ] = function (stat, buff)
	-- name = "Powerstone Pet damage reduc" 
	AdjustDamageReduction(stat, 30)
end
BuffModificationFunctions[11 ] = function (stat, buff)
	-- name = "Magic Defense Boost +1600mdef" 
	stat.magicdefensemod = stat.magicdefensemod - 1600
end
BuffModificationFunctions[7570 ] = function (stat, buff)
	-- name = "loophole" 
	--decrease ranged recieved damage 30%
	stat.incoming_ranged_damage_mul = stat.incoming_ranged_damage_mul + 30
end
BuffModificationFunctions[512 ] = function (stat, buff)
	-- name = "shadowplay buff" 
	stat.ranged_critical_rate = stat.ranged_critical_rate - 10
	stat.melee_critical_rate = stat.melee_critical_rate - 10
end
BuffModificationFunctions[2596 ] = function (stat, buff)
	-- name = "serp shield" 
	AdjustDamageReduction(stat, 30)
end
BuffModificationFunctions[552 ] = function (stat, buff)
	-- name = "blessing" 

end
BuffModificationFunctions[15106 ] = function (stat, buff)
	-- name = "hero cape cast time" 

end
BuffModificationFunctions[15780] = function (stat, buff)
	-- enna's energy

end
BuffModificationFunctions[20176] = function (stat, buff)
	-- elementally talanted

end
BuffModificationFunctions[11467] = function (stat, buff)
	-- seaknight
	stat.hasseaknight = true
end

BuffModificationFunctions[7652] = function (stat, buff)

end
BuffModificationFunctions[11249] = function (stat, buff)

end
BuffModificationFunctions[4951] = function (stat, buff)

end
BuffModificationFunctions[13612] = function (stat, buff)
	--battle focus rank 3

	-- melee critical damage + 25%
	stat.melee_critical_bonus = stat.melee_critical_bonus - 25
end
BuffModificationFunctions[404] = function (stat, buff)
	--battle focus rank 1

	-- melee critical damage + 15%
	stat.melee_critical_bonus = stat.melee_critical_bonus - 15
end
return BuffModificationFunctions