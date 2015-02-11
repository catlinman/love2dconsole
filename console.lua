
console = {} -- Base table containing all console variables and methods.
console.enabled = true -- If true the user is able to show/hide the console.
console.alert = true -- If true the console will display a widget on warnings and errors.

-- Configuration file tables.
console.style = {}
console.style.colors = {}
console.keys = {}

local commands = {} -- Table containing command callbacks.
local input = "" -- String containing a user entered string command.
local active = true -- If true the console will be shown.
local status = false -- Disable the console if there was a fatal error.
local statusMessage = "" -- Variable holding the last fatal error message.

local consoleStackSize = 100 -- Maximum number of lines stored in the console stack.
local consoleStack = {} -- Table containing the console printed lines.

-- Track the number of unchecked errors and warnings.
local warningCount = 0
local errorCount = 0

local cs = console.style -- Short name to keep things more tidy.
local screenWidth, screenHeight = love.graphics.getDimensions() -- Store the screen size.

-- Console functions that can be called outside of console.lua
-- Toggle the console.
function console.toggle()
	if active == false then
		active = true

		-- The console was opened and the errors were seen. Remove the outside widget.
		warningCount = 0
		errorCount = 0
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
	warningCount = 0
	errorCount = 0
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
function console.draw()
	if status == true and active == true then
		love.graphics.setColor(cs.colors.background.red, cs.colors.background.green, cs.colors.background.blue, cs.colors.background.alpha)
		love.graphics.rectangle("fill", 0, 0, screenWidth, 48 + cs.textMargin)

		love.graphics.setColor(cs.colors.outline.red, cs.colors.outline.green, cs.colors.outline.blue, cs.colors.outline.alpha)
		love.graphics.rectangle("fill", 0, 48 + cs.textMargin, screenWidth, cs.outlineSize)

		love.graphics.setColor(cs.colors.input.red, cs.colors.input.green, cs.colors.input.blue, cs.colors.input.alpha)
		love.graphics.print("> " ..input, 4, cs.textMargin)
	end
end

function console.keypressed(key)
	print(key)
	if console.enabled == true then
		if key == console.keys.toggle then
			if status == true then
				-- Update the screen size and display the console.
				screenWidth, screenHeight = love.graphics.getDimensions()
				console.toggle()
			else
				print("[Console] Failed to activate the console due to a fatal error: " ..statusMessage)
			end
		end
	end
end

function console.textinput(s)
	if status == true and active == true then
		input = input .. s
	end
end

-- Execute the configuration file and initialize user commands.
local loaded, chunk, message
loaded, chunk = pcall(love.filesystem.load, "console.conf.lua")
if not loaded then
	print('[Console] Failed to load the configuration file due to the following error: ' .. tostring(chunk))
	status = false
	statusMessage = message
else
	loaded, message = pcall(chunk)

	if not loaded then
		print('[Console] Executing the configuration file returned the following error: ' .. tostring(message))
		status = false
		statusMessage = message
	else
		status = true
	end
end