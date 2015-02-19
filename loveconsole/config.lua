
-- User configuration file for console.lua
-- We keep this file separate since it mainly consists of defining variables.

local config = {} -- Table containing the settings returned to the main system.

config.keys = {} -- Table containing the user defined keys.
config.colors = {} -- Table containing the console style colors.

config.enabled = true -- If true the user is able to show/hide the console.
config.alert = true -- If true the console will display a widget on warnings and errors.

config.inputChar = ">" -- Characters displayed at the start of the input line.
config.scrollChar = "..." -- Scroll handle characters.
config.cursorSpeed = 1.5 -- Speed at which the cursor blinks.
config.fontName = "" -- Filename of the font to be used. Leave it blank to use the default font.
config.fontSize = 10 -- Size of the console font.
config.consoleMarginEdge = 5 -- Left border margin of the console text.
config.consoleMarginTop = 0 -- Top border margin of the console text.
config.lineSpacing = 4 -- Space between individual lines.
config.outlineSize = 1 -- Outline height at the bottom of the console.
config.ignoreToggleKey = false -- If true, the toggle key will not be inputted to the console's input field.

config.stackMax = 100  -- Maximum number of lines stored in the console stack before old lines are removed.
config.sizeMin = 5 -- Minimum lines the console should display before extending to the max size.
config.sizeMax = 10 -- Maximum number of entries to print at a time.
config.shiftAmount = 1 -- Amount of lines to move over while scrolling up and down.

config.keys.toggle = "f10" -- Key used to toggle the console during runtime.
config.keys.scrollUp = "pageup" -- Key used to scroll up within the console's message stack.
config.keys.scrollDown = "pagedown" -- Key used to scroll down within the console's message stack.
config.keys.scrollTop = "home" -- Key used to move to the top of the stack.
config.keys.scrollBottom = "end" -- Key used to move to the bottom of the stack.
config.keys.inputUp = "up" -- Cycle up through the stack of last used commands.
config.keys.inputDown = "down" -- Cycle down through the stack of last used commands.
config.keys.cursorLeft = "left" -- Move the input cursor to the left.
config.keys.cursorRight = "right" -- Move the input cursor to the right.

-- Color tables used by the console. Change these to style the console to your liking.
-- Background color of the console window.
config.colors["background"] = {
	r = 0,
	g = 43,
	b = 54,
	a = 255
}

-- Color of the console outline.
config.colors["outline"] = {
	r = 88,
	g = 110,
	b = 117,
	a = 255
}

-- Default console basic text color.
config.colors["text"] = {
	r = 238,
	g = 232,
	b = 213,
	a = 255
}

-- Color of warning messages.
config.colors["warning"] = {
	r = 231,
	g = 207,
	b = 0,
	a = 255
}

-- Color of error messages.
config.colors["error"] = {
	r = 255,
	g = 75,
	b = 75,
	a = 255
}

-- Color of error messages.
config.colors["success"] = {
	r = 143,
	g = 253,
	b = 0,
	a = 255
}

-- Color of the console's input field.
config.colors["input"] = {
	r = 253,
	g = 246,
	b = 227,
	a = 255
}

return config