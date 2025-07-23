local BugSpeak = require("BugSpeak")

local speech = BugSpeak:new() -- Creates and activates a new speech object!
  :addSound('speak0')  -- you can add sounds individually, uses the same format as sounds['soundname']!
  :addSound({         -- you can also add a list of sounds all at once!
    'speak1',
    'speak2',
  })                    
  :setSpacesPause(true) -- sets wether or not spaces should make a sound.
  :setSubtitleVerb('yaps') -- sets the subtitle for your speech sound: '<Player> yaps'
  :setPolyphony(true) -- sets if multiple speech sounds can overlap
  :setRate(1) -- delay for speech
  :setVolume(.3) -- sets the volume of the sounds
  :setBasePitch(1) -- the pitch to add a random value to... (see pitch range)
  :setPitchRange(0.05) -- sets the range of pitches of the sounds played(-/+)