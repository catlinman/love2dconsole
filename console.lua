
console = {} -- Base table containing all console variables and methods.
console.enabled = true -- If true the user is able to show/hide the console.
console.alert = true -- If true the console will display a widget on warnings and errors.

-- Configuration file tables.
console.conf = {}
console.conf.colors = {}
console.conf.keys = {}

-- This variable contains the font data used by the console.
local basefont = love.graphics.getFont() -- Store the default font.
local consolefont = basefont -- Temporarily store the default font which will be overwritten later on.

local commands = {} -- Table containing command callbacks.
local inputfield = "" -- String containing a user entered string command.
local active = true -- If true the console will be shown.
local status = false -- Disable the console if there was a fatal error.
local statusMessage = "" -- Variable holding the last fatal error message.

local consoleStackSize = 100 -- Maximum number of lines stored in the console stack.
local consoleStack = {} -- Table containing the console printed lines.

-- Track the number of unchecked errors and warnings.
local warningCount, errorCount = 0, 0

local screenWidth, screenHeight = love.graphics.getDimensions() -- Store the screen size.

-- Console functions that can be called outside of console.lua
-- Toggle the console.
function console.toggle()
	if active == false then
		active = true

		-- The console was opened and the errors were seen. Remove the outside widget.
		warningCount, errorCount = 0, 0
	else
		active = false
	end
end

-- Print a string to the console.
function console.print(message)

end

-- Print a string to the console with warning styling.
function console.warning(message)
	warningCount = warningCount + 1
end

-- Print a string to the console with error styling.
function console.error(message)
	errorCount = errorCount + 1
end

-- Tell the console to execute a command from a string argument.
function console.execute(name)
	if commands[name] then
		commands[name].callback(commands[name].arguments)
	end
end

-- Clear the console.
function console.clear()
	consoleStack = {}
	warningCount, errorCount = 0, 0
end

-- Add a command to the command table.
function console.addCommand(name, callback, args)
	if not commands[name] then
		commands[name] = {["callback"] = callback, ["arguments"] = args}
	else
		print("[Console] The command with the name of " ..name " already exists in the command table.")
	end
end

-- Remove a command from the command table.
function console.removeCommand(name)
	if commands[name] then
		commands[name] = nil
		collectgarbage()
	else
		print("[Console] Unable to find the command with the name of " ..name " in the command table.")
	end
end

-- These functions need to be called from main.lua
-- Draw the console and it's contents.
function console.draw()
	if status == true and active == true then
		love.graphics.setFont(consolefont)

		love.graphics.setColor(console.conf.colors.background.r, console.conf.colors.background.g, console.conf.colors.background.b, console.conf.colors.background.a)
		love.graphics.rectangle("fill", 0, 0, screenWidth, (console.conf.fontSize * 2) + console.conf.textMargin)

		love.graphics.setColor(console.conf.colors.outline.r, console.conf.colors.outline.g, console.conf.colors.outline.b, console.conf.colors.outline.a)
		love.graphics.rectangle("fill", 0, (console.conf.fontSize * 2) + console.conf.textMargin, screenWidth, console.conf.outlineSize)

		love.graphics.setColor(console.conf.colors.input.r, console.conf.colors.input.g, console.conf.colors.input.b, console.conf.colors.input.a)
		love.graphics.print("> " ..inputfield, console.conf.textMargin, console.conf.textMargin)

		-- Reset the color and font in case someone decides to do drawing after the console (which doesn't make sense but who cares).
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setFont(basefont)
	end
end

-- Receive pressed keys and interpret them.
function console.keypressed(key)
	if console.enabled == true then
		if key == console.conf.keys.toggle then
			if status == true then
				-- Update the screen size and display the console.
				screenWidth, screenHeight = love.graphics.getDimensions()
				console.toggle()
			else
				print("[Console] Failed to activate the console due to a fatal error: " ..statusMessage)
			end
		elseif key == "return" then
			if active == true then

			end
		end
	end
end

-- Send text input to the console input field.
function console.textinput(s)
	if status == true and active == true then
		inputfield = inputfield .. s
	end
end

-- Execute the configuration file and initialize user commands.
local loaded, chunk, message
loaded, chunk = pcall(love.filesystem.load, "console.conf.lua")
if not loaded then
	print('[Console] Failed to load the configuration file due to the following error: ' .. tostring(chunk))
	status, active = false, false
	statusMessage = message
else
	loaded, message = pcall(chunk)

	if not loaded then
		print('[Console] Executing the configuration file returned the following error: ' .. tostring(message))
		status, active = false, false
		statusMessage = message
	else
		-- The file was loaded correctly.
		status = true

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
			print('[Console] Loading the custom defined console font returned the following error: ' .. tostring(message) ..' - reverting to the default font instead.')
		else
			consolefont = font 
		end
	end
end