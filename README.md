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
local BugSpeak = require('BugSpeak')
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

--!-------OR-------!--

-- Adds all sounds with IDs starting 'voice.talk'!
my_speech:addSounds('voice.talk')

```

### Mapping sounds to characters:
You can map your speech sounds to specific characters!

```lua
-- If you give addSound a table, you can specify what characters make what sounds!
my_speech:addSound({
    ['!'] = 'voice.exclaim',
    ['aeiou'] = {'voice.vowel1', 'voice.vowel2', 'voice.vowel3'},
    ['~'] = sounds['voice.uwu'], -- works with Sound objects, as well as strings.

    -- you can also add sounds normally here, which are the fallback if you haven't added a mapping.
    'voice.fallback1',
    'voice.fallback2'
})


-- Works with bulk sound adding!
my_speech:addSounds('voice.vowel', 'aeiou')
```


### Speech options:
```lua

-- The following functions return the speech object they were called on. --
    :setRate(1)                 -- delay for speech in ticks
    :setVolume(.3)              -- sets the volume of the played sounds
    :setBasePitch(1)            -- the pitch to add a random value to... (see pitch range)
    :setPitchRange(0.05)        -- sets the range of pitches of the sounds played(-/+)
    :setMaxLength(32)           -- sets the maximum number of characters to speak per chat message
    :setOneShot()               -- sets the maximum number of characters to speak to 1.
    :setPolyphony(true)         -- sets if multiple speech sounds can overlap
    :setSubtitleVerb('speaks')  -- sets the subtitle for your speech sound: '<Player> speaks'
    :setSpacesPause(true)       -- sets wether or not spaces should make a sound
    :setCallback(function(c)    -- sets the speech object's callback
        -- You can add callback functions every time a sound is played!
        -- 'c' is the spoken character.
        -- play some mouth animations, or something!
        -- always check player:isLoaded(), of course! 
    end)


    :play('testing testing')    -- appends a message to the speech queue, as if you entered a chat message.
    :stop()                     -- stops all speech sounds and clears the queue


-- The following functions do NOT return the speech object. (You really shouldn't use these.) --
    :playSpeechSound(c)         -- plays a single random speech sound, with a character.
                                -- Respects mappings.
    :tick()                     -- ticks the speech object. You should not use this function
                                -- unless you are making your own events.TICK function to
                                -- run BugSpeak.
```

# Recommendations
* [Microsoft Visual Studio Code](https://code.visualstudio.com/)
* [figura-vscode-extension](https://github.com/Manuel-3/figura-vscode-extension) by [Manuel-3](https://github.com/Manuel-3)

# Thank You
* @korbosoft - [KorboSpeak (FiguraMC Discord)](https://discord.com/channels/1129805506354085959/1238221345041678448)
* @manuel_2867 ([Manuel-3](https://github.com/Manuel-3)) - [Run Later (FiguraMC Discord)](https://discord.com/channels/1129805506354085959/1130769505514176583)
* *And users like you!*