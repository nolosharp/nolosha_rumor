Log = {}
local resourceName = GetCurrentResourceName()

---@param msg any
---@return string
local function formatMsg(msg)
    msg = msg ~= nil and msg or "nil"

    msg = type(msg) == "string" and msg or json.encode(msg)

    return msg
end

function Log.Warning(text, ...)
    if not Config.Debug then
        return
    end
    print("^3WARNING: ^7".. string.format(formatMsg(text), ...) .."^7")
end

function Log.error(text, ...)
    if not Config.Debug then
        return
    end
    print("^1ERROR: ^7".. string.format(formatMsg(text), ...) .."^7")
end

function Log.print(text, ...)
    if not Config.Debug then
        return
    end

    print("^2" .. resourceName .. ": ^7".. string.format(formatMsg(text), ...))
end

function Log.debug(text, ...)
    if not Config.Debug then
        return
    end

    print("^2DEBUG: ^7".. string.format(formatMsg(text), ...))
end