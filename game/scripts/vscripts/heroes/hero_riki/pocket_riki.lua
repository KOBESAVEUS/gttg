function GoToThePocket(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	--not target:HasModifier("modifier_vengefulspirit_hybrid_special")
	
	if target ~= caster and HasFreeSlot(target) and target:IsRealHero() and target == PlayerResource:GetSelectedHeroEntity(target:GetPlayerOwnerID()) then
		local item = CreateItem("item_pocket_riki", target, target)
		item.RikiContainer = caster
		local level = 1
		local invisAbility = caster:FindAbilityByName("riki_permanent_invisibility")
		if invisAbility and level < invisAbility:GetLevel() then
			level = invisAbility:GetLevel()
		end
		target:AddItem(item)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_pocket_riki_hide", {})
		caster:SetAbsOrigin(target:GetAbsOrigin())
		caster.PocketHostEntity = target
		caster.PocketItem = item
	else
		ability:RefundManaCost()
		ability:EndCooldown()
	end
end

function MoveUnit(keys)
	keys.caster:SetAbsOrigin(keys.caster.PocketHostEntity:GetAbsOrigin())
end

function HideUnit(keys)
	local caster = keys.caster
	caster:AddNoDraw()
	for i = 0, caster:GetAbilityCount()-1 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetName() ~= "riki_smoke_screen" then
			ability:SetActivated(false)
		end
	end
end

function ShowUnit(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveNoDraw()
	for i = 0, caster:GetAbilityCount()-1 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetName() ~= "riki_smoke_screen" then
			ability:SetActivated(true)
		end
	end
	caster.PocketHostEntity = nil
	caster.PocketItem = nil
end