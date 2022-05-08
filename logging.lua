-- local CURPATH = debug.getinfo(1,"S").source:match[[^@scripts\vscripts?(.*[\/])[^\/]-$]]
-- local logging = require(CURPATH .. "logging.logging")
local args = {...}
local directory = args[1]

print('directory is', directory)
if directory:match('logging') then
    directory = directory:match("(.*)logging")
end

local logging = require(directory..".lualogging.logging")
local IsDedicatedServer = IsDedicatedServer or function() return false end
local IsInToolsMode = IsInToolsMode or function() return false end
local IsServer = IsServer or function() return false end
local IsClient = IsClient or function() return false end
local IsConsole = function () return (not IsDedicatedServer() and not IsInToolsMode()) end
local Time = Time or function () return os.time() end

local function getMode()
	local side = ""
	if IsDedicatedServer() then
		side = "DEDICATE"
	elseif IsInToolsMode() then
		side = "TOOLS"
	elseif IsConsole() then
		side = "CONSOLE"
	end
	if IsServer() then
		side = side .. "_SERVER"
	elseif IsClient() then
		side = side .. "_CLIENT"
	end
	return side
end

local function splitPath(path)
	-- нарезаем путь, path - путь, file - имя файла, parent - родительская директория
	if path == "=(tail call)" then 
        return {path = "", parent="", file="lambda"} 
    end
	local sep = "\\"
	local s1 = path:find("@", 0)
	if s1 ~= nil then
		path = path:sub(s1 + 1)
	end
	local s = path:find(sep, 0)
	if s == nil then
		s = path:find("/", 0)
		if s ~= nil then
			sep = "/"
		end
	end

	local left = ""
	local right = path
	local parent = ""
	local s0 = 0
	while s ~= nil do
		left = path:sub(0, s - 1)
		parent = path:sub(s0+1, s - 1)
		right = path:sub(s + 1)
		--print(left.."---"..parent.."---"..right)
		s0 = s
		s = path:find(sep, s+1)
	end
	local withparent = right
	if parent ~= nil and parent ~= '.' and parent ~= "" then
		withparent = parent .. '/'.. right
	end

	return {
		path = left,
		parent = parent,
		file = right,
		withparent = withparent
	}
end

local function getTrace(level)
	local level = level or 3
	local info = debug.getinfo(level, "Sln")
	local res = {parent='', file='', line=0, withparent=''}
	-- print((info == nil and "nil" or self:table({info = info})))
	if not info then return res end
	local tmp = splitPath(info.source)
	res.line = info.currentline
	res.parent = tmp.parent
	res.withparent = tmp.withparent
	res.fname = tmp.file
	return res
end

local function traceback(level)
	local res = 'stack traceback:\n\t'
	local level = level or 3
	local sep = '\n\t'
	while true do
		local info = debug.getinfo(level, "Sln")
		-- print((info == nil and "nil" or self:table({info = info})))
		if not info then break end
		--if not info then return end
		if info.what == "C" then   -- is a C function?
			res = res .. "C function"
		elseif info.what == "tail" then
			res = res .. "lambda function"
		else   -- a Lua function
			local tmp = splitPath(info.source)
			local path = tmp.parent
			local fname = tmp.file
			local line = info.currentline

			local source = fname
			if path ~= nil and path ~= '.' and path ~= "" then
				source = path.."/"..fname
			end
			local method = "in main chunk"
			if info.namewhat == 'method' then
				method = string.format("in function %s", info.name)
			end
			res = string.format("%s%s:%d %s", res, source, line, method)
		end
	 	level = level + 1
		res = res..sep
		--sep = '\n\t'
	end
	return res
end

local function prepareLogMsg(pattern, dt, level, message, gameMode, trace)
    -- print(string.format("[%s][%05.2f] %-8s %-40s [%s:%d]",
	--	mode, Time(), LOGLEVEL, msg, trace.withparent, trace.line
	-- ))
    local logMsg = pattern or "[%date] [%gameMode] %level %message [%parent:%line]"
    message = string.gsub(message, "%%", "%%%%")
    logMsg = string.gsub(logMsg, "%%date", string.format("%05.2f", dt))
    logMsg = string.gsub(logMsg, "%%gameMode", gameMode)
    logMsg = string.gsub(logMsg, "%%level", string.format("%-8s", level))
    logMsg = string.gsub(logMsg, "%%message", string.format("%-40s", message))
    logMsg = string.gsub(logMsg, "%%parent", trace.withparent)
    logMsg = string.gsub(logMsg, "%%line", trace.line)
    return logMsg
end

function logging.dotalogging(params, ...)
    params = logging.getDeprecatedParams({"logPattern"}, params, ...)
    local logPattern = params.logPattern

    return logging.new(function (self, level, message)
        -- local s = logging.prepareLogMsg(logPattern, Time(), level, message)
        local gameMode = getMode()
        local trace = getTrace()
        local s = prepareLogMsg(logPattern, Time(), level, message, gameMode, trace)
        print(s)
        if level == 'ERROR' then
            print(traceback())
        end
        return true
    end)
end

return logging.dotalogging
