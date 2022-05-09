local directory = (...):match("(.-)[^%.]+$")
local try = require (directory..'try')
local prefix = '[HOOK_REQUIRE] '

local install = function()
    if oldrequire ~= nil then
        print(prefix..'require already rewrite hook not set')
        return nil
    end
    oldrequire = require
    function require(unit)
        print(prefix.."loading", unit)
        local res = try(function()
            return oldrequire(unit)
        end, function(e)
            err = e
            print(prefix.."WARNING loading failed ", e)
        end)
        return res
    end
end

local unistall = function()
    if oldrequire ~= nil then
        require = oldrequire
        oldrequire = nil
    end
end

local unit = {
    install=install,
    uninstall=unistall
}

return unit
