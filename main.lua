
-- Example main file to show the console functionality.

require("console") -- Require the console script.

function love.draw()
	love.graphics.setBackgroundColor(0, 0, 0) -- Set a lame background.
	console.draw() -- Draw the console at the end of the draw loop.
end

function love.keypressed(key)
	console.keypressed(key) -- Pass pressed keys to the console.
end

function love.textinput(t)
	console.textinput(t) -- Send text input to the console.
end