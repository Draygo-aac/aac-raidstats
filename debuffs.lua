local DebuffModificationFunctions = {}

local function AdjustDamageReduction(stat, amount)
	stat.incoming_spell_damage_mul	= stat.incoming_spell_damage_mul + amount   
	stat.incoming_melee_damage_mul  = stat.incoming_melee_damage_mul + amount
	stat.incoming_ranged_damage_mul = stat.incoming_ranged_damage_mul + amount
end
local function AdjustSkillDamage(stat, amount)
	stat.melee_damage_mul = stat.melee_damage_mul + amount
	stat.ranged_damage_mul = stat.ranged_damage_mul + amount
	stat.spell_damage_mul = stat.spell_damage_mul + amount
end
DebuffModificationFunctions[20023] = function (stat, buff)
	-- name = "Ouch, Hot"

end
DebuffModificationFunctions[5209] = function (stat, buff)
	-- name = "Clear Mind"

end
DebuffModificationFunctions[8000503 ] = function (stat, buff)
	-- name = "Powerstone Pet prevent" 
	
end
DebuffModificationFunctions[22290 ] = function (stat, buff)
	-- name = "no flight" 
	
end
DebuffModificationFunctions[467 ] = function (stat, buff)
	-- name = "no flight" 
	AdjustDamageReduction(stat, -12)
end

DebuffModificationFunctions[777 ] = function (stat, buff)
	-- name = "no flight" 
	AdjustSkillDamage(stat, 20)
end
DebuffModificationFunctions[771 ] = function (stat, buff)
	-- charmed

end
DebuffModificationFunctions[847 ] = function (stat, buff)
	-- bloody chanty -20%
	AdjustSkillDamage(stat, 20)
end
return DebuffModificationFunctions