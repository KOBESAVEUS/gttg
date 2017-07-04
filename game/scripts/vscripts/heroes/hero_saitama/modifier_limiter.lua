modifier_saitama_limiter = class({
	IsHidden   = function() return false end,
	GetTexture = function() return "arena/modifier_saitama_limiter" end,
	RemoveOnDeath = function() return false end,
})

function modifier_saitama_limiter:DeclareFunctions()
	return {
	MODIFIER_EVENT_ON_DEATH,
	}	
end

if IsServer() then
	function modifier_saitama_limiter:OnDeath(keys)
		local caster = self:GetCaster()
		local ability = caster:FindAbilityByName("saitama_limiter")
		if keys.attacker == caster and keys.unit:IsTrueHero() then
			self:SetStackCount(self:GetStackCount() + ability:GetLevelSpecialValueFor("stacks_for_kill", math.max(ability:GetLevel(), 1)))
		end
		if keys.unit == caster then
			local loss = math.round(caster:GetModifierStackCount("modifier_saitama_limiter", caster) * ability:GetLevelSpecialValueFor("loss_stacks_pct", math.max(ability:GetLevel(), 1)) * 0.01)
			self:SetStackCount(self:GetStackCount()-loss)
		end
	end
end