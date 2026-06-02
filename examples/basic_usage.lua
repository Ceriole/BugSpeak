local BugSpeak = require('BugSpeak')

-- This is a demonstration of most functions in the Speech object.
-- Do NOT just copy and paste this! This is not meant to be used as-is.

local speech = BugSpeak:new() -- Creates and activates a new speech object!
  
  :addSound('speak0')  -- you can add sounds individually, uses the same format as sounds['soundname']!
  :addSound({          -- you can also add a list of sounds all at once!
    'speak1',
    'speak2',
  })
  :addSound({         -- you can also map certain characters to sounds, so that they play when those characters are said!
    -- single character mapping
    ['!'] = 'exclaim',
    -- multiple character mapping, multiple random sounds
    ['?~'] = {'question_a', 'question_b', sounds['question_c']}, -- you can also have multiple sounds for a character, and it will randomly choose one to play!

    'fallback_talk' -- you can add a list of sounds without keys as well. Identical to addSound('fallback_talk')
  })

  -- You can also add all CUSTOM sounds in a directory at once! This also works as adding files only starting with the prefix. This uses sound IDs, not files. See sounds:getCustomSounds() in the Figura API.
  :addSounds('voice.talk') -- Adds sounds with the IDs 'voice.talk0', 'voice.talk1', etc. but does NOT add sounds with IDs like 'voice.talk.0' or 'voice.talk.1'!
  :addSounds('voice.vowel', 'aeiou') -- This also works with character mapping!

  :setSpacesPause(true) -- sets wether or not spaces should make a sound.
  
  :setSubtitleVerb('yaps') -- sets the subtitle for your speech sound: '<Player> yaps'
  
  :setRate(1) -- delay for speech
  :setVolume(.3) -- sets the volume of the sounds
  :setPolyphony(true) -- sets if multiple speech sounds can overlap
  
  :setBasePitch(1) -- the pitch to add a random value to... (see pitch range)
  :setPitchRange(0.05) -- sets the range of pitches of the sounds played(-/+)
  
  :setMaxLength(10) -- sets the maximum number of characters that can be queued at once. If the queue is full, new characters will be ignored until there is space.
  :setOneShot() -- sets the speech to only play one sound per speech, instead of a sound for each character. Identical to setMaxLength(1)
  
  :setCallback(function(c) -- sets a callback function that runs whenever a speech sound is played. Can be used for custom visualizers or other effects.
    print('played sound! char: ' .. c)
    -- If you use any player functions, make sure you check player:isLoaded().
  end)