function OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:GetClassname() == "ent_dota_tree" then
		ability:EndCooldown()
		ability:StartCooldown(ability:GetSpecialValueFor("alternative_cooldown"))
		target:CutDown(caster:GetTeamNumber())
	elseif target:IsCreep() then
		local doomling_health = ability:GetSpecialValueFor("doomling_health")
		local doomling_health_regen = ability:GetSpecialValueFor("doomling_health_regen")
		local doomling_mana = ability:GetSpecialValueFor("doomling_mana")
		local doomling_mana_regen = ability:GetSpecialValueFor("doomling_mana_regen")
		local doomling_damage_min = ability:GetSpecialValueFor("doomling_damage_min")
		local doomling_damage_max = ability:GetSpecialValueFor("doomling_damage_max")

		if caster.lucifers_claw_doomling_ent and not caster.lucifers_claw_doomling_ent:IsNull() and caster.lucifers_claw_doomling_ent:IsAlive() then
			caster.lucifers_claw_doomling_ent:Kill(ability, caster)
		end
		target:Kill(ability, caster)
		local doomling = CreateUnitByName("npc_dota_lucifers_claw_doomling", target:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
		doomling:SetControllableByPlayer(caster:GetPlayerID(), true)
		doomling:SetOwner(caster)
		for i = 0, target:GetAbilityCount()-1 do
			local ability = target:GetAbilityByIndex(i)
			if ability then
				local dAbility = doomling:AddAbility(ability:GetName())
				dAbility:SetLevel(ability:GetLevel())
			end
		end
		doomling:SetMaxHealth(doomling_health + target:GetMaxHealth())
		doomling:SetBaseMaxHealth(doomling_health + target:GetMaxHealth())
		doomling:SetHealth(doomling:GetMaxHealth())

		doomling:SetBaseHealthRegen(doomling_health_regen + target:GetBaseHealthRegen())

		doomling:SetManaGain(doomling_mana + target:GetMaxMana())
		doomling:SetBaseManaRegen(doomling_mana_regen + target:GetManaRegen())

		doomling:SetBaseDamageMin(doomling_damage_min + target:GetBaseDamageMin())
		doomling:SetBaseDamageMax(doomling_damage_max + target:GetBaseDamageMax())

		doomling:CreatureLevelUp(1)

		ability:ApplyDataDrivenModifier(caster, doomling, "modifier_item_lucifers_claw_lifesteal", {})
		
		caster.lucifers_claw_doomling_ent = doomling
	end
end

function ModifyCreepDamage(keys)
	local caster = keys.caster
	local target = keys.target
	if target:IsCreep() then
		local ability = keys.ability
		local damage = keys.damage
		local damage_bonus = keys.damage_bonus
		local damage_bonus_ranged = keys.damage_bonus_ranged
		local damage_table = {
			attacker = caster,
			victim = target,
			damage_type = DAMAGE_TYPE_HP_REMOVAL,
			ability = keys.ability
		}
		if IsRangedUnit(caster) then
			damage_table.damage = damage * ((damage_bonus_ranged - 100) / 100)
		else
			damage_table.damage = damage * ((damage_bonus - 100) / 100)
		end
		ApplyDamage(damage_table)
	end
end