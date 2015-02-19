
--[[

	LOVEConsole was created by Catlinman and can be forked on GitHub

	-> https://github.com/Catlinman/LOVEConsole

	This file allows for in-application executing and handling of function and variables allowing for more flexibility while debugging.

	Feel free to modify the file to your liking as long as I am credited for the original work.
	For more information please refer to the following link:

	-> https://github.com/Catlinman/LOVEConsole/blob/master/LICENSE.md
	
	The configuration file (config.lua) contains all the necessary settings for the console to work correctly.
	At the moment this means that if a variable within the configuration is not set the actual console will cause errors and not work.

--]]

local console = {} -- Base table containing all console variables and methods.
local config = {} -- Table containing console settings.

local baseFont = love.graphics.getFont() -- Store the default font.
local consoleFont = baseFont -- Temporarily store the default font which will be overwritten later on.

local consoleCommands = {} -- Table containing command callbacks.
local consoleInput = "" -- String containing a user entered string command.
local consoleActive = false -- If true the console will be shown.
local consoleStatus = "" -- Variable holding the last fatal error message.
local consoleCursorIndex = 0 -- Index of the input movement cursor.

local consoleStack = {} -- Table containing the console printed lines.
local consoleStackCount = 0 -- Current number of lines the console should accommodate for.
local consoleStackShift = 0 -- Amount of lines to shift the output stack by.

local consoleInputStack = {} -- Table containing the last user inputs. Has the same size as the main stack.
local consoleInputStackCount = 0 -- Number of input lines in the stack.
local consoleInputStackShift = 0 -- Amount of lines to shift the input stack by.

local warningCount, errorCount = 0, 0 -- Track the number of unchecked errors and warnings.

local screenWidth, screenHeight = love.graphics.getDimensions() -- Store the screen size.

-- Returns the current lua local path to this script.
local function scriptPath()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or ""
end

-- String splitting function.
function string.split(str, delim)
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

-- Insert a string into another string.
function string.insert(s1, s2, pos)
	return string.sub(s1, 1, pos) ..s2 ..string.sub(s1, pos + 1, #s1)
end

-- Drop a character a certain position.
function string.pop(str, pos)
	return string.sub(str, 1, pos) ..string.sub(str, pos + 2, #str)
end

-- Remove all UTF8 characters from a string.
function string.stripUTF8(str)
	return str:gsub('[%z\1-\127\194-\244][\128-\191]*', function(c) return #c > 1 and "" end)
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
		if #consoleStack > config.stackMax then
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
	if config.enabled then
		if state ~= true and state ~= false then
			consoleActive = not consoleActive

		elseif state or state == false then
			-- The console state was specified. Set the console to the desired state.
			consoleActive = state
		end

		if consoleActive then
			-- The console was opened and the errors were seen. Remove the outside widget.
			warningCount, errorCount = 0, 0
		end
	end
end

-- Print a string to the console. The optional color table must be defined as {r = v, g = v, b = v, a = v}.
function console.print(message, color)
	if config.enabled then
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
	if config.enabled then
		if message ~= nil then
			warningCount = warningCount + 1
			stackpush("Warning: " ..message, "warning")
		else
			stackpush("Please supply a value before sending a warning message to the console.", "warning")
		end
	end
end

-- Print a string to the console with success styling.
function console.success(message)
	if config.enabled then
		if message ~= nil then
			stackpush("Success: " ..message, "success")
		else
			stackpush("Please supply a value before sending a warning message to the console.", "warning")
		end
	end
end

-- Print a string to the console with error styling  and add to the error count.
function console.error(message)
	if config.enabled then
		if message ~= nil then
			errorCount = errorCount + 1
			stackpush("Error: " ..message, "error")
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

-- Tell the console to perform a command from a string argument.
function console.perform(line)
	local arguments = string.split(line, " ")
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
	if config.enabled and consoleActive then
		love.graphics.setFont(consoleFont) -- Prepare the console font.

		-- Draw the console background.
		love.graphics.setColor(config.colors["background"].r, config.colors["background"].g, config.colors["background"].b, config.colors["background"].a)
		love.graphics.rectangle(
			"fill",
			0,
			0,
			screenWidth,
			config.consoleMarginTop + config.fontSize * 2 + config.lineSpacing * math.max(math.min(consoleStackCount, config.sizeMax) + 1, config.sizeMin) +
				(math.max(math.min(consoleStackCount, config.sizeMax), config.sizeMin - 1) * config.fontSize)
		)

		-- Draw the console outline.
		love.graphics.setColor(config.colors["outline"].r, config.colors["outline"].g, config.colors["outline"].b, config.colors["outline"].a)
		love.graphics.rectangle(
			"fill",
			0,
			config.consoleMarginTop + config.fontSize * 2 + config.lineSpacing * math.max(math.min(consoleStackCount, config.sizeMax) + 1, config.sizeMin) +
				(math.max(math.min(consoleStackCount, config.sizeMax), config.sizeMin - 1) * config.fontSize),
			screenWidth,
			config.outlineSize
		)

		-- Draw the scroll indicators.
		if #consoleStack > config.sizeMax then
			love.graphics.setColor(config.colors["text"].r, config.colors["text"].g, config.colors["text"].b, config.colors["text"].a)

			-- Show scroll arrows if there are more lines to display.
			if consoleStackShift ~= math.min(#consoleStack - config.sizeMax, config.stackMax) then
				love.graphics.printf(config.scrollChar, screenWidth - config.consoleMarginEdge, config.consoleMarginTop, 1, "right")
			end

			if consoleStackShift ~= 0 then
				love.graphics.printf(config.scrollChar, screenWidth - config.consoleMarginEdge, config.consoleMarginTop + (config.lineSpacing * config.sizeMax) + (config.sizeMax * config.fontSize), 1, "right")
			end
		end

		-- Draw the message stack with the message coloring.
		for i in range(math.min(config.sizeMax, #consoleStack)) do
			local entry = consoleStack[math.max(1, (#consoleStack - math.min(config.sizeMax, #consoleStack) + i - consoleStackShift))]

			if type(entry.color) == "string" then
				if config.colors[entry.color] then
					local c = config.colors[entry.color]
					love.graphics.setColor(c.r, c.g, c.b, c.a)
				else
					love.graphics.setColor(config.colors["text"].r, config.colors["text"].g, config.colors["text"].b, config.colors["text"].a)
				end

			elseif type(entry.color) == "table" then
				local r, g, b, a = entry.color.r or 255, entry.color.g or 255, entry.color.b or 255, entry.color.a or 255
				love.graphics.setColor(r, g, b, a)

			else
				love.graphics.setColor(config.colors["text"].r, config.colors["text"].g, config.colors["text"].b, config.colors["text"].a)
			end

			love.graphics.print(tostring(entry.message), config.consoleMarginEdge, config.consoleMarginTop + (config.lineSpacing * i) + ((i - 1) * config.fontSize))
		end

		-- Draw the input line.
		local consoleInputEdited = consoleInput
		if math.ceil(os.clock() * config.cursorSpeed) % 2 == 0 then
			consoleInputEdited = string.insert(consoleInput ,"|", consoleCursorIndex)
		else
			consoleInputEdited = string.insert(consoleInput ," ", consoleCursorIndex)
		end

		love.graphics.setColor(config.colors["input"].r, config.colors["input"].g, config.colors["input"].b, config.colors["input"].a)
		love.graphics.print(string.format("%s %s", config.inputChar, consoleInputEdited), config.consoleMarginEdge,config.consoleMarginTop +
			(config.lineSpacing * math.max(math.min(consoleStackCount, config.sizeMax) + 1, 1)) +
			(math.min(consoleStackCount, config.sizeMax) * config.fontSize)
		)

		-- Reset the color and font in case someone decides to do drawing after the console (which doesn't make sense but who cares).
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setFont(baseFont)

	elseif config.enabled and config.alert and consoleActive == false then
		love.graphics.setFont(consoleFont) -- Prepare the console font.

		-- Draw the information widgets if the console is hidden and there are warnings and or errors.
		if warningCount > 0 or errorCount > 0 then
			local width = 6 * config.fontSize
			local height = config.fontSize * 1.5

			-- Draw the box outline border.
			love.graphics.setColor(config.colors["outline"].r, config.colors["outline"].g, config.colors["outline"].b, config.colors["outline"].a)
			love.graphics.rectangle("fill", 0, 0, width + config.outlineSize * 2, height + config.outlineSize * 2)

			-- Draw the box background.
			love.graphics.setColor(config.colors["background"].r, config.colors["background"].g, config.colors["background"].b, config.colors["background"].a)
			love.graphics.rectangle("fill", config.outlineSize, config.outlineSize, width, height)

			-- Draw the warning count.
			love.graphics.setColor(config.colors["warning"].r, config.colors["warning"].g, config.colors["warning"].b, config.colors["warning"].a)
			love.graphics.printf(math.min(9999, warningCount), config.outlineSize + (width / 5 + config.fontSize / 2), config.outlineSize + (config.fontSize / 6), 2, "center")

			-- Draw the error count.
			love.graphics.setColor(config.colors["error"].r, config.colors["error"].g, config.colors["error"].b, config.colors["error"].a)
			love.graphics.printf(math.min(9999, errorCount), width + config.outlineSize - (width / 5 + config.fontSize / 2), config.outlineSize + (config.fontSize / 6), 2, "center")
		end
	end
end

-- Tell LÖVE2D to allow repeating key presses. Comment this line if you don't want the given functionality.
love.keyboard.setKeyRepeat(true)

-- Receive pressed keys and interpret them.
function console.keypressed(key)
	if config.enabled then
		if key == config.keys.toggle then
			-- Update the screen size and display the console.
			screenWidth, screenHeight = love.graphics.getDimensions()
			console.toggle()

		elseif consoleActive then
			if key == "return" then
				if consoleInput ~= "" then
					if consoleInput:match("%S") then
						-- Store the line in the stack.
						if #consoleInputStack > config.stackMax then
							table.remove(consoleInputStack, 1)
						end

						consoleInputStack[#consoleInputStack + 1] = consoleInput
						consoleInputStackCount = #consoleInputStack

						-- Execute the given string command and reset the input field.
						console.perform(consoleInput)
						consoleInput = ""

						-- Also reset the stack shift.
						consoleStackShift = 0
						consoleInputStackShift = 0

						-- Reset the cursor index
						consoleCursorIndex = 0
					else
						consoleInput = ""
					end
				end

			elseif key == "backspace" then
				if consoleCursorIndex ~= 0 then
					consoleInput = string.pop(consoleInput, consoleCursorIndex - 1)
					consoleCursorIndex = math.max(consoleCursorIndex - 1, 0)
				end

			elseif key == "delete" then
				consoleInput = string.pop(consoleInput, consoleCursorIndex)

			elseif key == config.keys.scrollUp then
				if #consoleStack > config.sizeMax then
					-- Move the stack up.
					consoleStackShift = math.min(math.min(#consoleStack - config.sizeMax, config.stackMax), consoleStackShift + 1)
				end

			elseif key == config.keys.scrollDown then
				-- Move the stack down.
				consoleStackShift = math.max(consoleStackShift - 1, 0)
			
			elseif key == config.keys.scrollTop then
				-- Make sure that we can actually scroll and if so, move the stack shift to show the top most line.
				if #consoleStack > config.sizeMax then
					consoleStackShift = math.min(#consoleStack - config.sizeMax, config.stackMax)
				end

			elseif key == config.keys.scrollBottom then
				-- Set the shift amount to zero so the newest line is the last.
				consoleStackShift = 0

			elseif key == config.keys.scrollUp then
				if #consoleStack > config.sizeMax then
					-- Move the stack up.
					consoleStackShift = math.min(math.min(#consoleStack - config.sizeMax, config.stackMax), consoleStackShift + 1)
				end

			elseif key == config.keys.cursorLeft then
				consoleCursorIndex = math.max(consoleCursorIndex - 1, 0)

			elseif key == config.keys.cursorRight then
				consoleCursorIndex = math.min(consoleCursorIndex + 1, #consoleInput)

			elseif key == config.keys.inputUp then
				consoleInputStackShift = math.min(consoleInputStackShift + 1, #consoleInputStack)

				local entry = consoleInputStack[#consoleInputStack - consoleInputStackShift + 1]
				if entry then
					consoleInput = entry
				end

				consoleCursorIndex = #consoleInput

			elseif key == config.keys.inputDown then
				consoleInputStackShift = math.max(consoleInputStackShift - 1, 0)

				local entry = consoleInputStack[#consoleInputStack - consoleInputStackShift + 1]
				if consoleInputStackShift ~= 0 then
					consoleInput = entry
					consoleCursorIndex = #consoleInput
				else
					consoleInput = ""
					consoleCursorIndex = 0
				end
			end
		end
	end
end

-- Send text input to the console input field.
function console.textinput(s)
	-- If the key is the toggle key and the ignoreToggleKey option is enabled, clear the input.
	if config.ignoreToggleKey and s == config.keys.toggle then
		s = ""
	end

	if config.enabled and consoleActive and s ~= "" then
		-- Insert the character and clean out all UTF8 characters since they break everything otherwise.
		consoleInput = string.insert(consoleInput, string.stripUTF8(s), consoleCursorIndex)
		consoleCursorIndex = math.min(#consoleInput, consoleCursorIndex + 1)
	end
end

-- If the window is resized whilst the console is open, resize the console.
function console.resize(w, h)
	screenWidth, screenHeight = w, h
end

-- Execute the configuration file and initialize user consoleCommands.
local loaded, data
loaded, data = pcall(love.filesystem.load, scriptPath() .."config.lua")

if not loaded then
	print("[Console] Failed to load the configuration file due to the following error: " .. tostring(data))
	config.enabled, consoleActive, consoleStatus = false, false, data
else
	loaded, data = pcall(data)

	if not loaded then
		print("[Console] Executing the configuration file returned the following error: " .. tostring(data))
		config.enabled, consoleActive, consoleStatus = false, false, data
	else
		config = data

		-- Load font data.
		local fontstatus, data = pcall(
			function()
				if config.fontName ~= "" then
					return love.graphics.newFont(config.fontName, config.fontSize)
				else
					return love.graphics.newFont(config.fontSize)
				end
			end
		)
		if not fontstatus then
			print("[Console] Loading the custom defined console font returned the following error: " .. tostring(data) .." - reverting to the default font instead.")
		else
			consoleFont = data
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
		console.print("Missing required arguments")
	end
end, "Prints trailing command arguments as a formatted string - Arguments: [string to print]")

-- Executes a lua command and prints it's return value to the console.
console.addCommand("run", function(args)
	if args then
		local value = assert(loadstring(string.format("return %s", table.concat(args, " "))))()

		if value then
			console.print(string.format("Returned %s", tostring(value)))
		else
			console.print(string.format("Executing %s returned nil", table.concat(args, " ")))
		end
	else
		console.print("Missing the argument lua code to execute")
	end
end, "Executes the supplied lua function - Arguments: [lua command to execute] - Example: 'console.print(\"Do the fishstick!\")'")

-- Same as run with the difference of not returning a value and so avoiding errors while assigning new values to variables.
console.addCommand("set", function(args)
	if args then
		assert(loadstring(string.format('%s', table.concat(args, " "))))()
		console.print("Variable entry set")
	else
		console.print("Missing the argument lua code to set")
	end
end, "Sets a supplied variable - Arguments: [lua assignment to execute] - Example: 'console.enabled = false'")

-- Amazing help command of doom. It helps people.
console.addCommand("help", function(args)
	if not args then
		console.print("Available commands are:")
		for k, v in pairs(consoleCommands) do
			if v.description ~= "" then
				console.print(string.format("%s - %s", k, v.description), config.colors.success)
			else
				console.print(k, config.colors.success)
			end
		end
	else
		local name = table.concat(args, " ")
		if consoleCommands[name] then
			if consoleCommands[name].description then
				console.print(string.format("%s - %s", name, consoleCommands[name].description), {r = 0, g = 255, b = 0})
			else
				console.print(string.format("The command with the name of '%s' does not have a description.", name))
			end
		else
			console.print(string.format("The command with the name of '%s' was not found in the command table.", name))
		end
	end
end, "Outputs the names and descriptions of all available console commands or just a single one - Arguments: [command to fetch information on]")

-- Creates a new command entry that points to another command.
console.addCommand("alias", function(args)
	if args then
		if args[1] and args[2] then
			if consoleCommands[args[1]] then
				console.addCommand(args[2], consoleCommands[args[1]].callback, consoleCommands[args[1]].description)
				console.print(string.format("Successfully assigned the alias of '%s' to the command of '%s'.", args[2], args[1]))
			end
		else
			console.print("Missing command arguments. Requires two.")
		end
	else
		console.print("Missing command arguments. Requires two.")
	end
end, "Creates a new command list entry mimicking another command. Arguments: [command to alias] [alias name]")

return console