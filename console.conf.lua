
-- User configuration file for console.lua
-- We keep this file separate since it mainly consists of defining variables.

console.conf.enabled = true -- If true the user is able to show/hide the console.
console.conf.alert = true -- If true the console will display a widget on warnings and errors.

console.conf.fontName = "" -- Filename of the font to be used. Leave it blank to use the default font.
console.conf.fontSize = 10 -- Size of the console font.
console.conf.consoleMarginLeft = 4 -- Left border margin of the console text.
console.conf.consoleMarginTop = 0 -- Top border margin of the console text.
console.conf.lineSpacing = 4 -- Space between individual lines.
console.conf.outlineSize = 1 -- Outline height at the bottom of the console.

console.conf.stackMax = 100  -- Maximum number of lines stored in the console stack before old lines are removed.
console.conf.sizeMin = 5 -- Minimum lines the console should display before extending to the max size.
console.conf.sizeMax = 10 -- Maximum number of entries to print at a time.
console.conf.shiftAmount = 1 -- Amount of lines to move over while scrolling up and down.

console.conf.keys.toggle = "f10" -- Key used to toggle the console during runtime.
console.conf.keys.scrollUp = "pageup" -- Key used to scroll up within the console's message stack.
console.conf.keys.scrollDown = "pagedown" -- Key used to scroll down within the console's message stack.
console.conf.keys.scrollTop = "home" -- Key used to move to the top of the stack.
console.conf.keys.scrollBottom = "end" -- Key used to move to the bottom of the stack.

-- Color tables used by the console. Change these to style the console to your liking.
-- Background color of the console window.
console.conf.colors["background"] = {
	r = 0,
	g = 0,
	b = 0,
	a = 255
}

-- Color of the console outline.
console.conf.colors["outline"] = {
	r = 0,
	g = 200,
	b = 0,
	a = 255
}

-- Default console basic text color.
console.conf.colors["text"] = {
	r = 255,
	g = 255,
	b = 255,
	a = 255
}

-- Color of warning messages.
console.conf.colors["warning"] = {
	r = 255,
	g = 255,
	b = 25,
	a = 255
}

-- Color of error messages.
console.conf.colors["error"] = {
	r = 255,
	g = 75,
	b = 75,
	a = 255
}

-- Color of the console's input field.
console.conf.colors["input"] = {
	r = 255,
	g = 255,
	b = 255,
	a = 255
}

-- Declare custom commands at the end of this file.
-- Simple "Hello user" example command.
console.addCommand("hello", function(args)
	if args then
		console.print(string.format("Greetings %s!", args[1]))
	else
		console.print("Hey there!")
	end
end, "Greets you in a non rude way.")