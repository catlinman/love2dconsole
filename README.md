# LOVEConsole #

This is an in-application debugging and command console created for the [LÖVE2D game framework](https://love2d.org/). The console allows for rapid game testing by allowing the execution of user defined commands as well as native Lua functions. It also displays a useful overlay indicating a count of warnings and errors printed to the console to notify the user of any events that occur during execution.

## Installation and use ##

Getting LOVEConsole to run is a fairly simple and straightforward task. All that needs to be done to get started is to put *loveconsole* folder somewhere in you LÖVE2D project and to then *require* the folder from your *main.lua*. It is suggested that you do it from there since LOVEConsole requires you to hook some of LÖVE's main functions to it. This way it can receive information like key presses and also draw at the end of the main draw loop.

An example of how this can be done can either be seen in this repository's [*main.lua*](https://github.com/Catlinman/LOVEConsole/blob/master/main.lua) file or somewhat abstracted in the code below.

```lua
 -- Require the console script and assign it to a variable.
local console = require("loveconsole")

function love.draw()
	-- [Do main drawing operations before drawing the console.]
	love.graphics.pop() -- [Do this if you pushed any previous graphic translations.]
	console.draw()
end

function love.keypressed(key)
	-- [Handle key presses and then pass these on to the console.]
	console.keypressed(key)
end

function love.textinput(t)
	-- [Receive text input and pass it on to the console.]
	console.textinput(t)
end
```

From there on you can run your application as your normally would. At this point while your application is running you can hit *F10* to bring up the console. This can be done assuming you are using the default key bindings and have not made any changes to the configuration file as explained in the next section. If you've gotten this far your console is pretty much ready to be used. If you want to take it even further you should check out the next section.

## Configuring the console ##

Inside your *loveconsole* folder you will also find a file called *config.lua*. This is where LOVEConsole gets it's configuration from and it is crucial that the configuration file contains all of it's default values as specified in this repositories config file. If this is not the case the console will not be able to run and simply deactivate itself on load.

You can open the configuration file with your favorite text editing program and modify it to your liking. I've done my best to comment each configuration variable's use so it should be easy to edit and obtain your own personalized console. I also suggest that you define your custom console commands at the end of this file. You will find a sample command at the bottom of the file to see how commands can be created with ease. The benefit of using already defined commands comes with the fact that you have a lot more control over what they do and they are faster to type and perform over a native lua command which can be executed using the *run* built-in console command (further on that in the next section).

In the configuration file you will also find some variables which define the keys used to perform actions within the console window. You can find their default assignments in the table below.

<table>
  <tr align="center">
	<td><b>Key
	<td><b>Action
  </tr>
  <tr align="center">
	<td>F10
	<td>Toggle the console interface.
  </tr>
  <tr align="center">
	<td>Page Up
	<td>Scroll up the console log.
  </tr>
  <tr align="center">
	<td>Page Down
	<td>Scroll down the console log.
  </tr>
  <tr align="center">
	<td>Home
	<td>Move to the very beginning of the console log.
  </tr>
  <tr align="center">
	<td>End
	<td>Move to the newest message in the console log. 
  </tr>
  <tr align="center">
	<td>Up Arrow
	<td>Move up through the stack of previously entered commands.
  </tr>
  <tr align="center">
	<td>Down Arrow
	<td>Move down through the stack of previously entered commands.
  </tr>
  <tr align="center">
	<td>Left Arrow
	<td>Move the input cursor to the left.
  </tr>
  <tr align="center">
	<td>Right Arrow
	<td>Move the input cursor to the right.
  </tr>
</table>
## Built-in commands ##

LOVEConsole comes with a set of predefined commands which are declared towards the end of the *init.lua* file. Some of these are just to show what the console is capable of while others allow you to interface with native code. You can find a full listing of these commands in the table below.

<table>
  <tr align="center">
	<td><b>Command
	<td><b>Description
  </tr>
  <tr align="center">
	<td>help
	<td>Outputs the names and descriptions of all available console commands or just a single one - Arguments: [command to fetch information on]
  </tr>
  <tr align="center">
	<td>clear
	<td>Clears the entire console.
  </tr>
  <tr align="center">
	<td>quit
	<td>Attempts to close the application.
  </tr>
  <tr align="center">
	<td>print
	<td>Prints trailing command arguments as a formatted string - Arguments: [string to print]
  </tr>
  <tr align="center">
	<td>alias
	<td>Creates a new command list entry mimicking another command. Arguments: [command to alias] [alias name]
  </tr>
  <tr align="center">
	<td>run
	<td>Executes the supplied lua function - Arguments: [lua command to execute]
  </tr>
  <tr align="center">
	<td>set
	<td>Sets a supplied variable - Arguments: [lua assignment to execute]
  </tr>
</table>

## License ##

This repository is released under the MIT license. For more information please refer to [LICENSE](https://github.com/Catlinman/LOVEConsole/blob/master/LICENSE)
