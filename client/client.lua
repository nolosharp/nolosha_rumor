Ready = false
GracefulClose = false
TaskList = {}

---@type table<string, table>
NpcList = {} -- array of spawned npcs

---@type Prompt
local prompt = {}

local maxDst = Config.DevMode and 100 or 100
local displayDst = Config.DevMode and 100 or 15.0
local readDst = 4.0

local function deleteNpcs()
	for _, npcData in pairs(NpcList) do
		DeleteEntity(npcData.npc)
		DeletePed(npcData.npc)
		SetEntityAsNoLongerNeeded(npcData.npc)
	end
end

local function registerNpcs()
	for id, npcData in pairs(Config.Npcs) do
		local npc = SpawnNPC(npcData.model, npcData.coords)
		NpcList[id] = {
			coords = vector3(npcData.coords.x, npcData.coords.y, npcData.coords.z),
			spread = {
				center = vector3(npcData.spreading.center.x, npcData.spreading.center.y, npcData.spreading.center.z),
				radius = npcData.spreading.radius
			},
			npc = npc
		}
	end
end

AddEventHandler("onClientResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
		prompt = Prompt:new(Config.talkControl, "Parler", 0)
        Ready = true
		Wait(1000)

		if Config.DevMode then
			--TriggerServerEvent("emo_rumor:ask", "Quelqu'un m'a volé mon pantalon la nuit dernière !", 1)
			registerNpcs()
		end
    end
end)

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler("vorp:SelectedCharacter", function()
	deleteNpcs()
	Wait(10000)
    registerNpcs()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
		deleteNpcs()

		prompt:Delete()
        GracefulClose = true
    end
end)

RegisterNetEvent("emo_rumor:rumor")
AddEventHandler("emo_rumor:rumor", function (rumors)
	Rumors = rumors

	Log.print("Recieved rumors: %s", json.encode(rumors))
end)

RegisterNetEvent("emo_rumor:rumor:success")
AddEventHandler("emo_rumor:rumor:success", function ()
	TriggerEvent("vorp:TipRight", "Je commence à entendre ma rumeur être diffusé...", 5000)
end)

RegisterNetEvent("emo_rumor:rumor:fail")
AddEventHandler("emo_rumor:rumor:fail", function (cause)
	if cause == "delay" then
		TriggerEvent("vorp:TipRight", "Tu dois attendre avant de pouvoir diffuser une nouvelle rumeur.", 5000)
		return
	end

	if cause == "money" then
		TriggerEvent("vorp:TipRight", "Tu n'as pas assez d'argent pour diffuser une rumeur.", 5000)
		return
	end

	TriggerEvent("vorp:TipRight", "Ma Rumeur n'a pas pu être diffusé. (Tu gardes ton argent)", 5000)
end)

---@param cb function
---@param ... any
function LoopTask(cb, ...)
	local taskId = #TaskList + 1
	local args = {...}
	local stop = false

	Citizen.CreateThread(function()
		Wait(100) -- avoid race condition
		while not stop and not GracefulClose and cb(table.unpack(args)) do
			stop = stop == false and TaskList[taskId] == nil or stop
			Wait(0)
		end
		print("Conditons not met. Stopping Thread.")
	end)

	return taskId
end

function GetIsAnimal(entityId)
	return Citizen.InvokeNative(0x9A100F1CF4546629, entityId)
end

function IsEntityPNJ(entityId)
	local playerPed =  PlayerPedId()

	return playerPed ~= entityId and
	IsEntityAPed(entityId) and
	not GetIsAnimal(entityId) and
	not IsPedAPlayer(entityId)
end

function GetRumor(areaId, entityId)
	local crossArea = math.random() < Config.crossAreaChance

	-- local oldAreaId = areaId
	-- if crossArea then
	-- 	while oldAreaId == areaId and #Rumors > 1 do
	-- 		areaId = math.random(1, #Rumors)
	-- 	end
	-- end

	local rumors = Rumors[areaId].rumors
	if #rumors == 0 then
		return nil
	end

	print("number of rumor:", #rumors)
	local rumor = rumors[math.random(#rumors)]

	return rumor.rumor[math.random(#rumor.rumor)]
end

function SpreadRumor(entityId, areaId)
	local dst = GetDistanceFromEntity(entityId)

	local headBoneIdx = GetPedBoneIndex(entityId, 21030)

	if dst > displayDst then
		return
	end

	local rumor = GetRumor(areaId, entityId)
	if rumor then
		local taskId = LoopTask(function ()
			dst = GetDistanceFromEntity(entityId)
			local headPos = GetWorldPositionOfEntityBone(entityId, headBoneIdx)

			if dst > readDst then
				DrawText3D(dst, headPos, "!")
			else
				DrawText3D(dst, headPos, rumor)
			end


			return dst < maxDst
		end)
		TaskList[taskId] = entityId
	end
end

function SpreadRumors()
	TaskList = {}


	-- if #Rumors == 0 then
	-- 	print("no rumors in the list.")
	-- 	return
	-- end

	local playerCoords = GetEntityCoords(PlayerPedId())
	local closestArea = nil
	local closestAreaId = nil
	-- Get Closest Rumor Area
	for id, npcData in pairs(NpcList) do
		local dst = #(playerCoords - npcData.spread.center)
		Log.debug("Area %d: distance: %.2f", id, dst)
		if dst < npcData.spread.radius then
			closestArea = npcData.spread
			closestAreaId = id
			break
		end
	end

	if closestArea == nil or closestAreaId == nil then
		-- print("no rumor area nearby.")
		return
	end

	local rumor = Rumors[closestAreaId]
	print(closestAreaId, rumor)
	if rumor == nil or #rumor.rumors == 0 then
		-- print("no rumors in the area.")
		return
	end


	Wait(100) -- avoid race condition
	local pool = GetGamePool("CPed")

	local pnjs = Filter(pool, IsEntityPNJ)
	local neabryPnjs = Filter(pnjs, function (entityId)
		return GetDistanceFromCoords(entityId, closestArea.center) < closestArea.radius
	end)

	if #neabryPnjs == 0 then
		print("no pnjs nearby.")
		return
	end

	local pnjsWithRumor = Sample(neabryPnjs, Config.minRumor, Config.maxRumor)
	for i = 1, #pnjsWithRumor do
		SpreadRumor(pnjsWithRumor[i], closestAreaId)
	end
end

Citizen.CreateThread(function()
	while not Ready do
		Wait(100)
	end

	while not GracefulClose do
		-- print("Spreading Rumors")
		SpreadRumors()
		Wait(Config.rumorDuration * 1000)
	end
end)

local function askRumor(areaId)
	local input = {
		type = "enableinput",
		inputType = "textarea",
		button = "Diffuser la rumeur",
		placeholder = "Ecrivez la vérité ici.",
		style = "block",
		attributes = {
			inputHeader = "Diffusez une Rumeur",
			type = "text",
			pattern = "[A-Za-z ]{5,120}",
			title = "5 char min. 120 max.",
			style = "border-radius: 10px;\
			border:none;\
			min-height: 50px;\
			max-height: 100px;"
		}
	}

	TriggerEvent("vorpinputs:advancedInput", json.encode(input), function(data)
		local result = tostring(data)
		if result == nil or result == "" then
			return
		end

		if #result >= 120 then
			TriggerEvent("vorp:TipRight", "Votre rumeur est trop longue.", 5000)
			return
		end
		print("Asking Rumor: " .. result)
		print("areaID is:", areaId)
		TriggerServerEvent("emo_rumor:ask", result, areaId)
	end)
end


local function handleInteractions()
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)

	for id, npcData in pairs(NpcList) do
		local npcCoords = npcData.coords
		local dst = #(playerCoords - vector3(npcCoords.x, npcCoords.y, npcCoords.z))

		if dst < 10.0 then
			if dst > 2.0 then
				return
			end

			prompt:SetActiveGroupThisFrame()
			if prompt:IsPressed() then
				print("Talking to NPC from area with id:", id)
				askRumor(id)
				--TriggerServerEvent("emo_rumor:ask", "Quelqu'un m'a volé mon pantalon la nuit dernière !", id)
			end
			return
		end

	end
end

Citizen.CreateThread(function()
	while not Ready do
		Wait(100)
	end

	while not GracefulClose do
		Wait(0)
		handleInteractions()
	end
end)