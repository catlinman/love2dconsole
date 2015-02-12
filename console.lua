
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
local consoleActive = true -- If true the console will be shown.
local consoleStatus = false -- Disable the console if there was a fatal error.
local consoleStatusMessage = "" -- Variable holding the last fatal error message.

local consoleStack = {} -- Table containing the console printed lines.
local consoleStackCount = 0 -- Current number of lines the console should accommodate for.

local warningCount, errorCount = 0, 0 -- Track the number of unchecked errors and warnings.

local screenWidth, screenHeight = love.graphics.getDimensions() -- Store the screen size.

-- Pass a message to the console stack.
local function consolePass(message, type)
	if #consoleStack > console.conf.stackMax then
		table.remove(consoleStack, 1)
	end

	consoleStack[#consoleStack + 1] = {
		["message"] = message,
		["type"] = type
	}

	consoleStackCount = #consoleStack
end

-- Console functions that can be called outside of console.lua
-- Toggle the console.
function console.toggle()
	if consoleActive == false then
		consoleActive = true

		-- The console was opened and the errors were seen. Remove the outside widget.
		warningCount, errorCount = 0, 0
	else
		consoleActive = false
	end
end

-- Print a string to the console.
function console.print(message)
	consolePass(message, "default")
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
-- Draw the console and it"s contents.
function console.draw()
	if consoleStatus == true and consoleActive == true then
		love.graphics.setFont(consoleFont)

		love.graphics.setColor(console.conf.colors.background.r, console.conf.colors.background.g, console.conf.colors.background.b, console.conf.colors.background.a)
		love.graphics.rectangle(
			"fill",
			0,
			0,
			screenWidth,
			console.conf.consoleMarginTop + console.conf.fontSize * 2 + console.conf.lineSpacing * math.max(consoleStackCount + 1, 1) + consoleStackCount * console.conf.fontSize
		)

		love.graphics.setColor(console.conf.colors.outline.r, console.conf.colors.outline.g, console.conf.colors.outline.b, console.conf.colors.outline.a)
		love.graphics.rectangle(
			"fill",
			0,
			console.conf.consoleMarginTop + console.conf.fontSize * 2 + console.conf.lineSpacing * math.max(consoleStackCount + 1, 1) + consoleStackCount * console.conf.fontSize,
			screenWidth,
			console.conf.outlineSize
		)

		for i, entry in pairs(consoleStack) do
			love.graphics.setColor(console.conf.colors.input.r, console.conf.colors.input.g, console.conf.colors.input.b, console.conf.colors.input.a)
			love.graphics.print(entry.message, console.conf.consoleMarginLeft, console.conf.consoleMarginTop + (console.conf.lineSpacing * i) + ((i - 1) * console.conf.fontSize))
		end

		love.graphics.setColor(console.conf.colors.input.r, console.conf.colors.input.g, console.conf.colors.input.b, console.conf.colors.input.a)
		love.graphics.print("> " ..consoleInput, console.conf.consoleMarginLeft, console.conf.consoleMarginTop + (console.conf.lineSpacing * math.max(consoleStackCount + 1, 1)) + (consoleStackCount * console.conf.fontSize))

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