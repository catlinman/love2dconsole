
console = {} -- Base table containing all console variables and methods.
console.enabled = true -- If true the user is able to show/hide the console.
console.alert = true -- If true the console will display a widget on warnings and errors.

-- Configuration file tables.
console.conf = {}
console.conf.colors = {}
console.conf.keys = {}

local baseFont = love.graphics.getFont() -- Store the default font.
local consoleFont = baseFont -- Temporarily store the default font which will be overwritten later on.

local consoleCommands = {} -- Table containing command callbacks.
local consoleInput = "" -- String containing a user entered string command.
local consoleActive = false -- If true the console will be shown.
local consoleStatus = false -- Disable the console if there was a fatal error.
local consoleStatusMessage = "" -- Variable holding the last fatal error message.

local consoleStack = {} -- Table containing the console printed lines.
local consoleStackCount = 0 -- Current number of lines the console should accommodate for.

local warningCount, errorCount = 0, 0 -- Track the number of unchecked errors and warnings.

local screenWidth, screenHeight = love.graphics.getDimensions() -- Store the screen size.

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
local function consolePass(message, color)
	if #consoleStack > console.conf.stackMax then
		table.remove(consoleStack, 1)
	end

	consoleStack[#consoleStack + 1] = {
		["message"] = message,
		["color"] = color
	}

	consoleStackCount = #consoleStack
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
	if not color then
		consolePass(message, "default")
	else
		consolePass(message, color)
	end
end

-- Print a string to the console with warning styling.
function console.warning(message)
	warningCount = warningCount + 1
	consolePass(message, "warning")
end

-- Print a string to the console with error styling.
function console.error(message)
	errorCount = errorCount + 1
	consolePass(message, "error")
end

-- Tell the console to execute a command from a string argument.
function console.execute(name)
	if consoleCommands[name] then
		consoleCommands[name].callback(consoleCommands[name].arguments)
	end
end

-- Clear the console.
function console.clear()
	consoleStack = {}
	warningCount, errorCount = 0, 0
end

-- Add a command to the command table.
function console.addCommand(name, callback, args)
	if not consoleCommands[name] then
		consoleCommands[name] = {["callback"] = callback, ["arguments"] = args}
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

-- These functions need to be called from main.lua
-- Draw the console and it's contents.
function console.draw()
	if consoleStatus == true and consoleActive == true then
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

		love.graphics.setColor(console.conf.colors.outline.r, console.conf.colors.outline.g, console.conf.colors.outline.b, console.conf.colors.outline.a)
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
			local entry = consoleStack[math.max(1, (#consoleStack - math.min(console.conf.sizeMax, #consoleStack) + i))]
			if entry.color == "warning" then
				love.graphics.setColor(console.conf.colors.warning.r, console.conf.colors.warning.g, console.conf.colors.warning.b, console.conf.colors.warning.a)

			elseif entry.color == "error" then
				love.graphics.setColor(console.conf.colors.error.r, console.conf.colors.error.g, console.conf.colors.error.b, console.conf.colors.error.a)

			elseif type(entry.color) == "table" then
				local r, g, b, a = entry.color.r or 255, entry.color.g or 255, entry.color.b or 255, entry.color.a or 255
				love.graphics.setColor(r, g, b, a)
			else
				love.graphics.setColor(console.conf.colors.text.r, console.conf.colors.text.g, console.conf.colors.text.b, console.conf.colors.text.a)
			end

			love.graphics.print(entry.message, console.conf.consoleMarginLeft, console.conf.consoleMarginTop + (console.conf.lineSpacing * i) + ((i - 1) * console.conf.fontSize))
		end

		-- Draw the input line.
		love.graphics.setColor(console.conf.colors.input.r, console.conf.colors.input.g, console.conf.colors.input.b, console.conf.colors.input.a)
		love.graphics.print("> " ..consoleInput, console.conf.consoleMarginLeft,console.conf.consoleMarginTop +
			(console.conf.lineSpacing * math.max(math.min(consoleStackCount, console.conf.sizeMax) + 1, 1)) +
			(math.min(consoleStackCount, console.conf.sizeMax) * console.conf.fontSize)
		)

		-- Reset the color and font in case someone decides to do drawing after the console (which doesn"t make sense but who cares).
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setFont(baseFont)
	end
end

-- Receive pressed keys and interpret them.
function console.keypressed(key)
	if console.enabled == true then
		if key == console.conf.keys.toggle then
			if consoleStatus == true then
				-- Update the screen size and display the console.
				screenWidth, screenHeight = love.graphics.getDimensions()
				console.toggle()
			else
				print("[Console] Failed to activate the console due to a fatal error: " ..consoleStatusMessage)
			end
		elseif key == "return" then
			if consoleActive == true then
				console.print(string.format('"%s"', consoleInput))
				consoleInput = ""
			end
		end
	end
end

-- Send text input to the console input field.
function console.textinput(s)
	if consoleStatus == true and consoleActive == true then
		consoleInput = consoleInput .. s
	end
end

-- Execute the configuration file and initialize user consoleCommands.
local loaded, chunk, message
loaded, chunk = pcall(love.filesystem.load, "console.conf.lua")
if not loaded then
	print("[Console] Failed to load the configuration file due to the following error: " .. tostring(chunk))
	consoleStatus, consoleActive = false, false
	consoleStatusMessage = message
else
	loaded, message = pcall(chunk)

	if not loaded then
		print("[Console] Executing the configuration file returned the following error: " .. tostring(message))
		consoleStatus, consoleActive = false, false
		consoleStatusMessage = message
	else
		-- The file was loaded correctly.
		consoleStatus = true

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