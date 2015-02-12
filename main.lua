
-- Example main file to show the console functionality.

require("console") -- Require the console script.

function love.load()
	console.toggle(true) -- Toggle the console on.

	-- Example of printing to the console with custom colors.
	console.print("You are running LOVEConsole Version 0.1", {r = 0, g = 150, b = 255, a = 255})
end

function love.draw()
	love.graphics.setBackgroundColor(10, 25, 50) -- Set a lame background.
	console.draw() -- Draw the console at the end of the draw loop.
end

function love.keypressed(key)
	console.keypressed(key) -- Pass pressed keys to the console.
end

function love.textinput(t)
	console.textinput(t) -- Send text input to the console.
end