
-- User configuration file for console.lua
-- We keep this file separate since it mainly consists of defining variables.

local conf = {} -- Table containing the settings returned to the main system.

conf.keys = {} -- Table containing the user defined keys.
conf.colors = {} -- Table containing the console style colors.

conf.enabled = true -- If true the user is able to show/hide the console.
conf.alert = true -- If true the console will display a widget on warnings and errors.

conf.inputChar = ">" -- Characters displayed at the start of the input line.
conf.scrollChar = "..." -- Scroll handle characters.
conf.cursorSpeed = 1.5 -- Speed at which the cursor blinks.
conf.fontName = "" -- Filename of the font to be used. Leave it blank to use the default font.
conf.fontSize = 10 -- Size of the console font.
conf.consoleMarginEdge = 5 -- Left border margin of the console text.
conf.consoleMarginTop = 0 -- Top border margin of the console text.
conf.lineSpacing = 4 -- Space between individual lines.
conf.outlineSize = 1 -- Outline height at the bottom of the console.

conf.stackMax = 100  -- Maximum number of lines stored in the console stack before old lines are removed.
conf.sizeMin = 5 -- Minimum lines the console should display before extending to the max size.
conf.sizeMax = 25 -- Maximum number of entries to print at a time.
conf.shiftAmount = 1 -- Amount of lines to move over while scrolling up and down.

conf.keys.toggle = "f10" -- Key used to toggle the console during runtime.
conf.keys.scrollUp = "pageup" -- Key used to scroll up within the console's message stack.
conf.keys.scrollDown = "pagedown" -- Key used to scroll down within the console's message stack.
conf.keys.scrollTop = "home" -- Key used to move to the top of the stack.
conf.keys.scrollBottom = "end" -- Key used to move to the bottom of the stack.
conf.keys.inputUp = "up" -- Cycle up through the stack of last used commands.
conf.keys.inputDown = "down" -- Cycle down through the stack of last used commands.
conf.keys.cursorLeft = "left" -- Move the input cursor to the left.
conf.keys.cursorRight = "right" -- Move the input cursor to the right.

-- Color tables used by the console. Change these to style the console to your liking.
-- Background color of the console window.
conf.colors["background"] = {
	r = 0,
	g = 43,
	b = 54,
	a = 255
}

-- Color of the console outline.
conf.colors["outline"] = {
	r = 88,
	g = 110,
	b = 117,
	a = 255
}

-- Default console basic text color.
conf.colors["text"] = {
	r = 238,
	g = 232,
	b = 213,
	a = 255
}

-- Color of warning messages.
conf.colors["warning"] = {
	r = 231,
	g = 207,
	b = 0,
	a = 255
}

-- Color of error messages.
conf.colors["error"] = {
	r = 255,
	g = 75,
	b = 75,
	a = 255
}

-- Color of error messages.
conf.colors["success"] = {
	r = 143,
	g = 253,
	b = 0,
	a = 255
}

-- Color of the console's input field.
conf.colors["input"] = {
	r = 253,
	g = 246,
	b = 227,
	a = 255
}

return conf