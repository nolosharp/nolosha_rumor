local api_key = GetConvar("openai_api_key", "")
local model = "gpt-3.5-turbo-16k-0613"

---@class Message
---@field role string "system" | "user" | "assistant"
---@field content string

---@type Message
local systemMessage = {
    role = "system",
    content = "you are a villager from the far west. You speak with a strong country accent from the year 1840 and have a strong personnality. You live in a western city."
}

---@class FunctionDescriptorParameterProperty
---@field type string "string" | "number" | "boolean" | "object" | "array"
---@field description string
---@field enum table<number, string>?
---@field items FunctionDescriptorParameterProperty?


---@class FunctionDescriptorParameter
---@field type string
---@field properties table<string, FunctionDescriptorParameterProperty>
---@field required table<number, string>?

---@class FunctionDescriptor
---@field name string
---@field description string
---@field parameters FunctionDescriptorParameter

local function getRumorList(data)
    local rumors = data["rumors"]

    return rumors
end

---@type FunctionDescriptor
local getRumorListDescription = {
    name = "getRumorList",
    description = "Get the list of rumors",
    parameters = {
        type = "object",
        properties = {
            rumors = {
                type = "array",
                description = "The list of rumors",
                items = {
                    type = "string",
                    description = "A rumor"
                }
            }
        },
        required = {"rumors"}
    }
}

local functionCallMap = {
    getRumorList = getRumorList
}

---@param rumor string
---@param author string
---@return Message
function GetPrompt(rumor, author)
    return {
        role = "user",
        --content = string.format("Voici un évènement raconté par %s: \"%s\". Donne moi une liste de phrase en français pour raconter cette rumeur.", author, rumor)
        content = string.format("Voici un évènement raconté par %s: \"%s\".\n\
        Donne moi une liste de phrase en français pour répandre l'histoire sous forme de rumeur.\n\
        Utilise le nom de l'auteur quand l'evenement est à la première personne.", author, rumor)
    }
end

---@param url string
---@param method string
---@param header table
---@param body string
---@return string, string?
local function doRequest(url, method, header, body)
    local err = nil
    local res = ''
    local done = false

	PerformHttpRequest(url, function(statusCode, response, headers)
		if statusCode ~= 200 then
			error("Error: " .. statusCode, statusCode)
			return
		end

		local data = json.decode(response)
		if not data then
			error("No Data returned from request", statusCode)
            done = true
			return
		end

        res = response
        done = true
	end, method, body, header)

    while not done do
        Wait(0)
    end

    return res, err
end

-- Function to perform a completion request on the OpenAI API
function Complete(rumor, author)
    -- Set up the request URL
    local url = "https://api.openai.com/v1/chat/completions"

    -- Set up the request headers
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. api_key
    }

    local prompt = GetPrompt(rumor, author)

    -- Set up the request body
    local body = {
        model = model,
        messages = {systemMessage, prompt},
        functions = {getRumorListDescription},
        n = 1,
    }

    -- Encode the request body as JSON
    local json_body = json.encode(body)

    -- Send the request
    local res = doRequest(url, "POST", headers, json_body)


    -- Decode the response body from JSON
    local response = json.decode(res)
    local content = nil

    local message = response["choices"][1]["message"]
    if message["function_call"] ~= nil then
        local functionCall = message["function_call"]
        local functionName = functionCall["name"]
        local functionArgs = json.decode(functionCall["arguments"])

        content = functionCallMap[functionName](functionArgs)
    else
        content = message["content"]
    end

    return content
end

function ValidateAPIKey()
    if #api_key == 0 then
        print("OpenAI API key not set. Please set it in your server.cfg file.")
        print("example: set openai_api_key \"<your api key here>\" # https://platform.openai.com/account/api-keys")
        return false
    end

    return true
end