function GetDistanceFromEntity(entityId)
	local playerPed = PlayerPedId()
	--local ped = GetPlayerPed(playerPed)
    local playerCoords = GetEntityCoords(playerPed, true, true)
	local entityCoords = GetEntityCoords(entityId, true, true)

	return #(entityCoords - playerCoords)
end

function GetDistanceFromCoords(entityId, coords)
	--local ped = GetPlayerPed(playerPed)
	local entityCoords = GetEntityCoords(entityId, true, true)

	return #(entityCoords - coords)
end

function Filter(array, cmp)
	local result = {}

	for _, value in ipairs(array) do
		if cmp(value) then
			table.insert(result, value)
		end
	end

	return result
end

-- return sample of array
function Sample(array, minSize, maxSize)
	local size = math.random(minSize, maxSize)
	local result = {}

	for i = 1, size do
		local index = math.random(1, #array)
		table.insert(result, array[index])
	end

	return result
end

function GetOffset(dst)
	local min = -0.16
	local max = -0.10
	local maxDst = 10.0
	local minDst = 1.0

	-- the closer we are the lower the offset. clamp between min and max
	local offset = min + (max - min) * (dst - minDst) / (maxDst - minDst)
	offset = math.min(offset, max)

	--print("offset: " .. offset)

	return 0.0
end

function DrawText3D(dst, position, text)
	local success, _x, _y = GetScreenCoordFromWorldCoord(position.x, position.y, position.z + 0.3)
	local offset = GetOffset(dst)

	if not success then
		return false
	end

	SetTextScale(0.35, 0.35)
	SetTextFontForCurrentCommand(1)
	SetTextColor(255, 255, 255, 215)
	local str = CreateVarString(10, "LITERAL_STRING", text)
	Citizen.InvokeNative(0xBE5261939FBECB8C, 1)
	DisplayText(str, _x, _y + offset)
	local factor = #text / 150.0
	--DrawSprite("generic_textures", "hud_menu_4a", _x, _y + offset + 0.0125, 0.015 + factor, 0.03, 0.1, 100, 1, 1, 190, 0)

	return true
end

function LoadModel(model)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end
end

function SpawnNPC(model, coords)
    LoadModel(model)
	local npc = CreatePed(model, vector3(coords.x, coords.y, coords.z), coords.h, false, true)
	Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
	while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C,npc) do
		Citizen.Wait(0)
	end
	SetEntityCanBeDamaged(npc, false)
	SetEntityInvincible(npc, true)
	Wait(500)
	Citizen.InvokeNative(0x9587913B9E772D29, npc, true)
	FreezeEntityPosition(npc, true)
	SetBlockingOfNonTemporaryEvents(npc, true)

	return npc
end