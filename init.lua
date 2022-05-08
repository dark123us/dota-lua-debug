local args = {...}
local directory = args[1]
print('---directory---', directory)
print('hello abc')

logging = require(directory..'.logging')
-- local logging = require(directory .. '.logging.logging')
-- local dotalogging = require(directory..'.dotalogging')

local units = {
    logging=logging
}

return units

