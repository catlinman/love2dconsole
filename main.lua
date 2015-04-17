
-- Example main file to show the console functionality.

local console = require("loveconsole") -- Require the console script.

function love.load()
	-- Example of printing to the console with custom colors.
	console.print("You are running LOVEConsole by Catlinman", {r = 0, g = 150, b = 255, a = 255})
	console.warning("Wow what a warning. Something is about to break.")
	console.error("Many error very scare.")
	console.success("User is spooked.")

	-- We define custom commands using the addCommand method.
	-- A simple "Hello user" example command can be seen below.
	console.addCommand("hello", function(args)
		if args then
			console.print(string.format("Greetings %s!", args[1]))	
		else
			console.print("Hey there!")
		end
	end, "Greets you in a non rude way - Arguments: [person to say hello to]")

end

function love.draw()
	love.graphics.setBackgroundColor(10, 25, 50) -- Set a lame background.

	-- Keep in mind to call love.graphics.pop() if you performed any translation changes using love.graphics.push()
	console.draw() -- Draw the console at the end of the draw loop.
end

function love.keypressed(key)
	console.keypressed(key) -- Pass pressed keys to the console.
end

function love.textinput(t)
	console.textinput(t) -- Send text input to the console.
end

function love.resize(w, h)
	console.resize(w, h) -- Resize the console if the window is resized.
end
