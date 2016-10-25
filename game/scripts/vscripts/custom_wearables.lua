if not CustomWearables then
	_G.CustomWearables = class({})
end

function CustomWearables:Unit(unit)
	if not unit.CustomWearables then unit.CustomWearables = {Attachments = {}, ParticleMap = {}} end
end

function CustomWearables:TranslateParticle(unit, particle)
	return unit.CustomWearables.ParticleMap[particle] or particle
end

function CustomWearables:EquipWearables(unit, herokey)
	if not herokey then
		herokey = GetFullHeroName(unit) or unit:GetUnitName()
	elseif type(herokey) == "table" and herokey:entindex() then
		herokey = GetFullHeroName(herokey)
	end
	if unit.WearablesRemoved then
		for _,v in pairs(unit:GetChildren()) do
			if v:GetClassname() == "dota_item_wearable" then
				v:AddEffects(EF_NODRAW)
				v:SetModel("models/development/invisiblebox.vmdl")
				--child:RemoveSelf()
			end
		end
	end
	local wearables = CustomWearables:GetPlayerHeroWearables(unit, herokey)
	for _,v in ipairs(wearables) do
		CustomWearables:EquipWearable(unit, v)
	end
end

function CustomWearables:EquipWearable(unit, handle)
	CustomWearables:Unit(unit)
	if handle.models and type(handle.models) == "table" and #handle.models > 0 then
		for _,v in ipairs(handle.models) do
			CustomWearables:EquipWearableModel(unit, v)
		end
	end
	if handle.particles and type(handle.particles) == "table" and table.count(handle.particles) > 0 then
		for k,v in pairs(handle.particles) do
			if unit.CustomWearables.ParticleMap[k] then
				print("[CustomWearables:EquipWearable] Unit already has a particle in particle map, override: unit, key, oldValue, newValue", unit:GetUnitName(), k, unit.CustomWearables.ParticleMap[k], v)
			end
			unit.CustomWearables.ParticleMap[k] = v
		end
	end
	if handle.hidden_slots and type(handle.hidden_slots) == "table" and #handle.hidden_slots > 0 then
		for _,v in ipairs(handle.hidden_slots) do
			if CosmeticLib:_Identify( unit ) then
				CosmeticLib:RemoveFromSlot( unit, v )
				unit._cosmeticlib_wearables_slots[v].handle:AddEffects(EF_NODRAW)
				for k,_ in pairs(unit._cosmeticlib_wearables_slots) do print(k) end
			end
			--Attachments:Attachment_HideCosmetic({index = unit:GetEntityIndex(), PlayerID = unit:GetPlayerID(), model = GetModelName()})
		end
	end
	return
	--[[TODO
	if handle.custom_slots and type(handle.custom_slots) == "table" and #handle.custom_slots > 0 then
		for k,v in ipairs(handle.custom_slots) do
			if CosmeticLib:_Identify( unit ) then
				CustomWearables:EquipCustomModelToSlot(unit, k, v)
			end
		end
	end]]
end

function CustomWearables:UnequipAllWearables(unit)
	CustomWearables:Unit(unit)
	for _,v in ipairs(unit.CustomWearables.Attachments) do
		UTIL_Remove(v)
	end
	unit.CustomWearables = nil
	CustomWearables:Unit(unit)
end

function CustomWearables:EquipWearableModel(unit, modelHandle)
	CustomWearables:Unit(unit)
	local a = Attachments:AttachProp(unit, modelHandle.attachPoint or "attach_hitloc", modelHandle.model or "models/development/invisiblebox.vmdl", modelHandle.scale or 1.0, modelHandle.properties)
	if modelHandle.callback then modelHandle.callback(a) end
	table.insert(unit.CustomWearables.Attachments, a)
end

function CustomWearables:EquipCustomModelToSlot(unit, slot_name, model_name)
	CustomWearables:Unit(unit)
	if CosmeticLib:_Identify( unit ) then
		local handle_table = unit._cosmeticlib_wearables_slots[ slot_name ]
		if handle_table then
			handle_table[ "handle" ]:SetModel( model_name )
			handle_table[ "item_id" ] = nil
		end
	end
end

function CustomWearables:GetPlayerHeroWearables(unitvar, herokey)
	local wearables = {}
	if type(herokey) == "table" and herokey:entindex() then
		herokey = GetFullHeroName(herokey)
	end
	local playerID = UnitVarToPlayerID(unitvar)
	if playerID and playerID > -1 then
		local steamid = PlayerResource:GetSteamAccountID(playerID)
		if CUSTOM_WEARABLES_PLAYER_ITEMS[steamid] and CUSTOM_WEARABLES_PLAYER_ITEMS[steamid][herokey] then
			for _,v in ipairs(CUSTOM_WEARABLES_PLAYER_ITEMS[steamid][herokey]) do
				local h = CustomWearables:WearableNameToHandle(v)
				if h then
					table.insert(wearables, h)
				end
			end
		end
	end
	return wearables
end

function CustomWearables:WearableNameToHandle(wearable)
	return CUSTOM_WEARABLES_ITEM_HANDLES[wearable]
end
-----------------------------------------------------------------------------------------
--Function remap
-----------------------------------------------------------------------------------------
function CDOTA_BaseNPC:EquipWearable(handle)
	CustomWearables:Unit(self)
	return CustomWearables:EquipWearable(self, handle)
end
function CDOTA_BaseNPC:UnequipAllWearables()
	CustomWearables:Unit(self)
	CustomWearables:UnequipAllWearables(self)
end
function CDOTA_BaseNPC:TranslateParticle(particle)
	CustomWearables:Unit(self)
	return CustomWearables:TranslateParticle(self, particle)
end