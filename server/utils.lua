function TryN(tries, func, ...)
    local args = {...}
    local success, result = pcall(func, table.unpack(args))
    if not success then
        if tries > 0 then
            return TryN(tries - 1, func, table.unpack(args))
        else
            return nil, result
        end
    else
        return result, nil
    end
end