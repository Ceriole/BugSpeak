# BugSpeak -<br>A FiguraMC Library for Animal Crossing-Equse Speech
A moderately simple library for adding animal-crossing like speech to characters!

A massive thank you to @korbosoft for making [KorboSpeak (FiguraMC Discord)](https://discord.com/channels/1129805506354085959/1238221345041678448), which this is heavily based upon!!!
If you're worried about size, please check it out as it is much smaller!
The library is fully documented within the included LUA file.

# How to use
*Make sure you have `BugSpeak.lua` next to your  `script.lua`!*

Download [BugSpeak.lua](BugSpeak.lua) and add it to your Figura Avatar directory.

### To include BugSpeak:
```lua
local BugSpeak = require("BugSpeak")
```

### To create a new speech object:
```lua
-- This will create a new BugSpeak.Speech object *and* activate it.
local my_speech = BugSpeak:new()
-- ... configure my_speech ...

--!-------OR-------!--

-- This will create a new BugSpeak.Speech object and *will not* activate it.
local my_speech = BugSpeak.Speech:new()
-- ... configure my_speech ...

-- Be sure to activate the speech object.
BugSpeak:activate(my_speech)
```
### To add speech sounds:
Add your sounds as `*.ogg` files into your avatar folder.
```lua
-- One sound
my_speech:addSound('path.to.my.speech.sound')

--!-------OR-------!--

-- Multiple sounds
my_speech:addSound({'path.to.my.speech.sound1', 'path.to.my.speech.sound2'})

--!-------OR-------!--

-- As sound resources
my_speech:addSound(sounds['path.to.my.speech.sound'])
```

### Please check the [Wiki](https://github.com/Ceriole/BugSpeak/wiki) for more information!

# Recommendations
* [Microsoft Visual Studio Code](https://code.visualstudio.com/)
* [figura-vscode-extension](https://github.com/Manuel-3/figura-vscode-extension) by [Manuel-3](https://github.com/Manuel-3)

# Thank You
* @korbosoft - [KorboSpeak (FiguraMC Discord)](https://discord.com/channels/1129805506354085959/1238221345041678448)
* @manuel_2867 ([Manuel-3](https://github.com/Manuel-3)) - [Run Later (FiguraMC Discord)](https://discord.com/channels/1129805506354085959/1130769505514176583)
* *And users like you!*