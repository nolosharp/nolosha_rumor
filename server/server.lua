FakeRumors = {
    "J'ai entendu dire que la pluie va déferler sur nos terres dans les prochains jours.",
    "On raconte que les nuages sombres annoncent une bonne averse qui va nous rendre visite.",
    "Les vieux habitants du coin murmurent que la pluie est sur le point de s'abattre sur nous."
}
VorpCore = {}
AuthorRegistry = {} -- [author] = {rumorTxt, askedAt}

TriggerEvent("getCore", function(core)
	VorpCore = core
end)


AddEventHandler("onServerResourceStart", function (resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    Log.print("Starting emo_rumors Server...")

    if not ValidateAPIKey() then
        return
    end


    -- populate rumors areas
    for id, npcData in pairs(Config.Npcs) do
        Rumors[id] = {
            id = id,
            rumors = {}
        }
    end

    print(json.encode(Rumors))

    if Config.DevMode then
        Log.print("Dev mode enabled. Rumor range will be increased.")

        Wait(3000)
        --TriggerClientEvent("emo_rumor:rumor", -1, FakeRumors)
    end
end)

RegisterServerEvent("emo_rumor:ask")
AddEventHandler("emo_rumor:ask", function (message, areaId)
    if not ValidateAPIKey() then
        return
    end

    local _source = source
    local character = VorpCore.getUser(_source).getUsedCharacter

    if character.money < Config.price then
        TriggerClientEvent("emo_rumor:rumor:fail", _source, "money")
        return
    end

    local lastAsked = AuthorRegistry[character.charIdentifier]

    if lastAsked ~= nil and os.time() - lastAsked.askedAt < Config.rumorAskingDelay * 1000 then
        TriggerClientEvent("emo_rumor:rumor:fail", _source, "delay")
        return
    end

    local author = string.format("%s %s", character.firstname, character.lastname)

    print("processing...")
    local rumors, err = TryN(3, Complete, message, author)

    if err ~= nil then
        print("Error performing completion request: " .. tostring(err))
        TriggerClientEvent("emo_rumor:rumor:fail", _source)
        return
    end

    if rumors == nil or #rumors == 0 then
        Log.error("Error generating rumor")
        TriggerClientEvent("emo_rumor:rumor:fail", _source)
        return
    end

    Log.debug("Generated rumors done!")
    print("Area ID is:", areaId)
    print(json.encode(Rumors))
    
    local t1 = Rumors[areaId]
    print("Area is nil ?", t1 == nil)
    if t1 ~= nil then
        local t2 = #t1.rumors
        print("nb of rumors in area:", tostring(t2))
    end

    Rumors[areaId].rumors[#Rumors[areaId].rumors+1] = {
        rumor = rumors,
        createdAt = os.time()
    }

    character.removeCurrency(0, Config.price)
    AuthorRegistry[character.charIdentifier] = {
        rumorTxt = message,
        askedAt = os.time()
    }

    TriggerClientEvent("emo_rumor:rumor", -1, Rumors)
    TriggerClientEvent("emo_rumor:rumor:success", _source)
end)

Citizen.CreateThread(function ()
    -- check every 60 sec if a rumor is outdated
    while true do
        Wait(60000)

        local validRumors = {}
        for id, rumor in pairs(Rumors) do
            local remainingRumors = {}
            for _, r in pairs(rumor.rumors) do
                if os.time() - r.createdAt < Config.rumorValidity * 1000 then
                    remainingRumors[#remainingRumors+1] = r
                end
            end

            rumor.rumors = remainingRumors

            validRumors[id] = rumor
        end

        Rumors = validRumors

        TriggerClientEvent("emo_rumor:rumor", -1, Rumors)
    end
end)