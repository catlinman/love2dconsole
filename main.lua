
-- Example main file to show the console functionality.

require("console")

function love.draw()
	love.graphics.setBackgroundColor(50, 180, 255)
	console.draw()
end

function love.keypressed(key)
	console.keypressed(key)
end

function love.textinput(t)
	console.textinput(t)
end