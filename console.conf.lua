
-- User configuration file for console.lua
-- We keep this file sepperate since it mainly constists of defining variables.

-- Background color of the console window.
console.conf.colors.background = {
	r = 0,
	g = 0,
	b = 0,
	a = 255
}

-- Color of the console outline.
console.conf.colors.outline = {
	r = 0,
	g = 200,
	b = 0,
	a = 255
}

-- Default console basic text color.
console.conf.colors.text = {
	r = 255,
	g = 255,
	b = 255,
	a = 255
}

-- Color of warning messages.
console.conf.colors.warning = {
	r = 255,
	g = 255,
	b = 25,
	a = 255
}

-- Color of error messages.
console.conf.colors.error = {
	r = 255,
	g = 75,
	b = 75,
	a = 255
}

-- Color of the console's input field.
console.conf.colors.input = {
	r = 255,
	g = 255,
	b = 255,
	a = 255
}

console.conf.fontName = "" -- Filename of the font to be used. Leave it blank to use the default font.
console.conf.fontSize = 10 -- Size of the console font.
console.conf.consoleMarginLeft = 4 -- Left border margin of the console text.
console.conf.consoleMarginTop = 0 -- Top border margin of the console text.
console.conf.lineSpacing = 4 -- Space between individual lines.
console.conf.outlineSize = 1 -- Outline height at the bottom of the console.

console.conf.stackMax = 100  -- Maximum number of lines stored in the console stack before old lines are removed.
console.conf.sizeMin = 5 -- Minimum lines the console should display before extending to the max size.
console.conf.sizeMax = 10 -- Maximum number of entries to print at a time.

console.conf.keys.toggle = "f10" -- Key used to toggle the console during runtime.
console.conf.keys.scrollUp = "pageup" -- Key used to scroll up within the console's message stack.
console.conf.keys.scrollDown = "pagedown" -- Key used to scroll down within the console's message stack.