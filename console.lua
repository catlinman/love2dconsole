
--[[

	LOVEConsole was created by Catlinman and can be forked on GitHub

	-> https://github.com/Catlinman/LOVEConsole

	This file allows for in-application executing and handling of function and variables allowing for more flexibility while debugging.

	Feel free to modify the file to your liking as long as I am credited for the original work. For more information please
	refer to the following link:

	-> https://github.com/Catlinman/LOVEConsole/blob/master/LICENSE.md
	
	The configuration file (console.conf.lua) contains all the necessary settings for the console to work correctly.
	At the moment this means that if a variable within the configuration is not set the actual console will cause errors and not work.

--]]

console = {} -- Base table containing all console variables and methods.

-- Configuration file tables.
console.conf = {}
console.conf.colors = {}
console.conf.keys = {}

local baseFont = love.graphics.getFont() -- Store the default font.
local consoleFont = baseFont -- Temporarily store the default font which will be overwritten later on.

local consoleCommands = {} -- Table containing command callbacks.
local consoleInput = "" -- String containing a user entered string command.
local consoleActive = false -- If true the console will be shown.
local consoleStatus = "" -- Variable holding the last fatal error message.

local consoleStack = {} -- Table containing the console printed lines.
local consoleStackCount = 0 -- Current number of lines the console should accommodate for.
local consoleStackShift = 0 -- Amount of lines to shift the output by.

local warningCount, errorCount = 0, 0 -- Track the number of unchecked errors and warnings.

local screenWidth, screenHeight = love.graphics.getDimensions() -- Store the screen size.

-- String splitting function.
local function split(str, delim)
	if string.find(str, delim) == nil then
		return {str}
	end

	local result = {}
	local pat = "(.-)" .. delim .. "()"
	local nb = 0
	local lastPos

	for part, pos in string.gfind(str, pat) do
		nb = nb + 1
		result[nb] = part
		lastPos = pos
	end

	result[nb + 1] = string.sub(str, lastPos)

	return result
end

-- Range iterator function.
local function range(a, b, step)
	if not b then
		b = a
		a = 1
	end
	step = step or 1
	local f = step > 0 and
		function(_, lastvalue)
			local nextvalue = lastvalue + step
			if nextvalue <= b then return nextvalue end
		end or
		step < 0 and
		function(_, lastvalue)
			local nextvalue = lastvalue + step
			if nextvalue >= b then return nextvalue end
		end or
		function(_, lastvalue) return lastvalue end
	return f, nil, a - step
end

-- Pass a message to the console stack.
local function stackpush(message, color)
	if message ~= nil then
		if #consoleStack > console.conf.stackMax then
			table.remove(consoleStack, 1)
		end

		consoleStack[#consoleStack + 1] = {
			["message"] = message,
			["color"] = color
		}

		consoleStackCount = #consoleStack
	end
end

-- Console functions that can be called outside of console.lua
-- Toggle the console.
function console.toggle(state)
	if not state then
		if consoleActive == false then
			consoleActive = true
		else
			consoleActive = false
		end
	elseif state == true then -- The console state was specified. Set the console to the desired state.
		consoleActive = true
	else
		consoleActive = false
	end

	if consoleActive == true then
		-- The console was opened and the errors were seen. Remove the outside widget.
		warningCount, errorCount = 0, 0
	end
end

-- Print a string to the console. The optional color table must be defined as {r = v, g = v, b = v, a = v}.
function console.print(message, color)
	if console.conf.enabled == true then
		if message ~= nil then
			if not color then
				stackpush(message, "default")
			else
				stackpush(message, color)
			end
		else
			stackpush("Please supply a value before printing to the console.", "warning")
		end
	end
end

-- Print a string to the console with warning styling and add to the warning count.
function console.warning(message)
	if console.conf.enabled == true then
		if message ~= nil then
			warningCount = warningCount + 1
			stackpush(message, "warning")
		else
			stackpush("Please supply a value before sending a warning message to the console.", "warning")
		end
	end
end

-- Print a string to the console with error styling  and add to the error count.
function console.error(message)
	if console.conf.enabled == true then
		if message ~= nil then
			errorCount = errorCount + 1
			stackpush(message, "error")
		else
			stackpush("Please supply a value before sending an error message to the console.", "warning")
		end
	end
end

-- Add a command to the command table. Callback is the function executed when the command is run.
function console.addCommand(name, callback, description)
	if not consoleCommands[name] then
		consoleCommands[name] = {["callback"] = callback, ["description"] = description or ""}
	else
		print("[Console] The command with the name of " ..name " already exists in the command table.")
	end
end

-- Remove a command from the command table.
function console.removeCommand(name)
	if consoleCommands[name] then
		consoleCommands[name] = nil
		collectgarbage()
	else
		print("[Console] Unable to find the command with the name of " ..name " in the command table.")
	end
end

-- Tell the console to execute a command from a string argument.
function console.execute(line)
	local arguments = split(line, " ")
	local command = arguments[1]

	-- Remove the command argument from the argument table
	table.remove(arguments, 1)

	if consoleCommands[command] then
		local status, err

		if arguments[1] then
			status, err = pcall(
				function()
					 consoleCommands[command].callback(arguments)
				end
			)
		else
			status, err = pcall(
				function()
					 consoleCommands[command].callback()
				end
			)
		end

		if err then
			console.print(string.format("Executing %s returned the following error: %s", command, tostring(err)))
		end
	else
		console.print(string.format("Unknown command '%s'", command))
	end
end

-- Clear the console.
function console.clear()
	consoleStack = {}
	consoleStackCount = 0
	warningCount, errorCount = 0, 0
end

-- These functions need to be called from main.lua
-- Draw the console and it's contents.
function console.draw()
	if console.conf.enabled == true and consoleActive == true then
		love.graphics.setFont(consoleFont)

		love.graphics.setColor(console.conf.colors.background.r, console.conf.colors.background.g, console.conf.colors.background.b, console.conf.colors.background.a)
		love.graphics.rectangle(
			"fill",
			0,
			0,
			screenWidth,
			console.conf.consoleMarginTop + console.conf.fontSize * 2 + console.conf.lineSpacing * math.max(math.min(consoleStackCount, console.conf.sizeMax) + 1, console.conf.sizeMin) +
				(math.max(math.min(consoleStackCount, console.conf.sizeMax), console.conf.sizeMin - 1) * console.conf.fontSize)
		)

		love.graphics.setColor(console.conf.colors["outline"].r, console.conf.colors["outline"].g, console.conf.colors["outline"].b, console.conf.colors["outline"].a)
		love.graphics.rectangle(
			"fill",
			0,
			console.conf.consoleMarginTop + console.conf.fontSize * 2 + console.conf.lineSpacing * math.max(math.min(consoleStackCount, console.conf.sizeMax) + 1, console.conf.sizeMin) +
				(math.max(math.min(consoleStackCount, console.conf.sizeMax), console.conf.sizeMin - 1) * console.conf.fontSize),
			screenWidth,
			console.conf.outlineSize
		)

		-- Draw the message stack with the message coloring.
		for i in range(math.min(console.conf.sizeMax, #consoleStack)) do
			local entry = consoleStack[math.max(1, (#consoleStack - math.min(console.conf.sizeMax, #consoleStack) + i - consoleStackShift))]

			if type(entry.color) == "string" then
				if console.conf.colors[entry.color] then
					local c = console.conf.colors[entry.color]
					love.graphics.setColor(c.r, c.g, c.b, c.a)
				else
					love.graphics.setColor(console.conf.colors["text"].r, console.conf.colors["text"].g, console.conf.colors["text"].b, console.conf.colors["text"].a)
				end

			elseif type(entry.color) == "table" then
				local r, g, b, a = entry.color.r or 255, entry.color.g or 255, entry.color.b or 255, entry.color.a or 255
				love.graphics.setColor(r, g, b, a)

			else
				love.graphics.setColor(console.conf.colors["text"].r, console.conf.colors["text"].g, console.conf.colors["text"].b, console.conf.colors["text"].a)
			end

			love.graphics.print(tostring(entry.message), console.conf.consoleMarginLeft, console.conf.consoleMarginTop + (console.conf.lineSpacing * i) + ((i - 1) * console.conf.fontSize))
		end

		-- Draw the input line.
		love.graphics.setColor(console.conf.colors["input"].r, console.conf.colors["input"].g, console.conf.colors["input"].b, console.conf.colors["input"].a)
		love.graphics.print("> " ..consoleInput, console.conf.consoleMarginLeft,console.conf.consoleMarginTop +
			(console.conf.lineSpacing * math.max(math.min(consoleStackCount, console.conf.sizeMax) + 1, 1)) +
			(math.min(consoleStackCount, console.conf.sizeMax) * console.conf.fontSize)
		)

		-- Reset the color and font in case someone decides to do drawing after the console (which doesn't make sense but who cares).
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setFont(baseFont)
	end
end

-- Tell LÖVE2D to allow repeating key presses. Comment this line if you don't want the given functionality.
love.keyboard.setKeyRepeat(true)

-- Receive pressed keys and interpret them.
function console.keypressed(key)
	if console.conf.enabled == true then
		if key == console.conf.keys.toggle then
			-- Update the screen size and display the console.
			screenWidth, screenHeight = love.graphics.getDimensions()
			console.toggle()

		elseif key == "return" then
			if consoleActive == true then
				console.execute(consoleInput)
				consoleInput = ""
			end

		elseif key == "backspace" then
			if consoleActive == true then
				consoleInput = string.gsub(consoleInput, "[^\128-\191][\128-\191]*$", "")
			end

		elseif key == console.conf.keys.scrollUp then
			if consoleActive == true then
				if #consoleStack > console.conf.sizeMax then
					-- Move the stack up.
					consoleStackShift = math.min(math.min(#consoleStack - console.conf.sizeMax, console.conf.stackMax), consoleStackShift + 1)
				end
			end

		elseif key == console.conf.keys.scrollDown then
			if consoleActive == true then
				-- Move the stack down.
				consoleStackShift = math.max(0, consoleStackShift - 1)
			end
		
		elseif key == console.conf.keys.scrollTop then
			if consoleActive == true then
				if #consoleStack > console.conf.sizeMax then
					consoleStackShift = math.min(#consoleStack - console.conf.sizeMax, console.conf.stackMax)
				end
			end

		elseif key == console.conf.keys.scrollBottom then
			if consoleActive == true then
				consoleStackShift = 0
			end
		end
	end
end

-- Send text input to the console input field.
function console.textinput(s)
	if console.conf.enabled == true and consoleActive == true and s ~= "" then
		consoleInput = consoleInput .. s
	end
end

-- Execute the configuration file and initialize user consoleCommands.
local loaded, chunk, message
loaded, chunk = pcall(love.filesystem.load, "console.conf.lua")
if not loaded then
	print("[Console] Failed to load the configuration file due to the following error: " .. tostring(chunk))
	console.conf.enabled, consoleActive, consoleStatus = false, false, message
else
	loaded, message = pcall(chunk)

	if not loaded then
		print("[Console] Executing the configuration file returned the following error: " .. tostring(message))
		console.conf.enabled, consoleActive, consoleStatus = false, false, message
	else
		-- Load font data.
		local fontstatus, font = pcall(
			function()
				if console.conf.fontName ~= "" then
					return love.graphics.newFont(console.conf.fontName, console.conf.fontSize)
				else
					return love.graphics.newFont(console.conf.fontSize)
				end
			end
		)
		if not fontstatus then
			print("[Console] Loading the custom defined console font returned the following error: " .. tostring(message) .." - reverting to the default font instead.")
		else
			consoleFont = font 
		end
	end
end

-- Some base functions to make life just a little easier.

-- We wrap functions in a custom callback.
console.addCommand("clear", function() console.clear() end, "Clears the entire console.")
console.addCommand("quit", function() love.event.quit() end, "Attempts to close the application.")

-- Command callbacks can also receive a table of string arguments.
console.addCommand("print", function(args)
	if args then
		console.print(table.concat(args, " "))
	else
		-- Error is returned to the console. In case of console.execute, error is returned to the "out" variable.
		error("Missing required arguments")
	end
end, "Prints out the supplied arguments.")

console.addCommand("run", function(args)
	if args then
		func = args[1]
		table.remove(args, 1)
		assert(loadstring(string.format('return %s(%s)', func, table.concat(args, " "))))()
	else
		-- Error is returned to the console. In case of console.execute, error is returned to the "out" variable.
		error("Missing required arguments")
	end
end, "Executes the supplied lua function.")

console.addCommand("set", function(args)
	if args then
		var = args[1]
		table.remove(args, 1)
		assert(loadstring(string.format('%s = %s', var, table.concat(args, " "))))()
	else
		-- Error is returned to the console. In case of console.execute, error is returned to the "out" variable.
		error("Missing required arguments")
	end
end, "Sets a supplied variable.")

console.addCommand("help", function()
	console.print("Available commands are:")
	for k, v in pairs(consoleCommands) do
		if v.description ~= "" then
			console.print(string.format("%s - %s", k, v.description), {r = 0, g = 255, b = 0})
		else
			console.print(k, {r = 0, g = 255, b = 0})
		end
	end
end, "Outputs the names and descriptions of all available console commands.")

