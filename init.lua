local args = {...}
local directory = args[1]..'.'
-- print('args0 is '..tostring(args[0]))
-- print('... '..tostring((...)))
-- print(' = '.. (...):match("(.-)[^%.]+$"))

local logging = require(directory..'logging')
local try = require(directory..'try')
local hook_require = require(directory .. 'hook_require')

-- local logging = require(directory .. '.logging.logging')
-- local dotalogging = require(directory..'.dotalogging')

local units = {
    logging=logging,
    try=try,
    hook_require=hook_require
}

return units

