local try = function(func, catch_func)
    local status, data = pcall(func)
    if not status then
        catch_func(data)
    end
    return data
end

return try

