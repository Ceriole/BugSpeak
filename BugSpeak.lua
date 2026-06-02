---BugSpeak v0.1.2 by @ceriole
---Loosely based upon KorboSpeak by @korbosoft


--- I highly recommend not changing this value.
--- This is to prevent abuse/annoyance from trying to play too many sounds at once.
local SAFE_SPEECH_LENGTH = 64


---@class RunLater
---@author @manuel_2867
---@author @ceriole
---@field tmrs [RunLater.Timer]
---@field t number
local RunLater = {tmrs={}, t=0}

---@alias RunLater.predicate fun(): boolean

---@class RunLater.Timer
---@author @ceriole
---@field t number|false
---@field p RunLater.predicate|number
---@field n function

---Schedules a function to run after a certain amount of ticks
---@param ticks number|RunLater.predicate Amount of ticks to wait, or a predicate function to check each tick until it returns true
---@param next function Function to run after amount of ticks, or after the predicate function returned true
function RunLater.add(ticks, next)
	if not next then return end
    local is_delay= type(ticks) == 'number'
    table.insert(RunLater.tmrs, {
		t = is_delay and RunLater.t + ticks,
		p = is_delay and function()end or ticks,
		n = next
	})
end

---RunLater tick function. Runs functions added by RunLater.add.
---@see RunLater.add
function RunLater.tick()
    RunLater.t = RunLater.t+1
    for key,timer in pairs(RunLater.tmrs) do
        if timer.p() or (timer.t and RunLater.t >= timer.t) then
            timer.n()
            RunLater.tmrs[key]=nil
        end
    end
end


---@alias Speech.SpeechCallback function<string> callback function that runs whenever a speech sound is played. Can be used for custom visualizers or other effects. Set by Speech.setCallback.

---Speech object.
---@class Speech
---@field private sounds table<string, [Sound]> A list of sound resources. Use mono channel sounds, otherwise they will be heard globally!
---@field private rate integer Rate of speech, how many ticks to wait per speech sound.
---@field private volume number Volume of speech sound.
---@field private basePitch number The base pitch to start at. nil = 1.0
---@field private pitchRange number Range of pitch randomization. Zero or nil disables random pitch.
---@field private maxLength integer Maximum amount of text characters to speak.
---@field private polyphony boolean Set to true if you want speech sounds to overlap.
---@field private subtitleVerb string The subtitle to display when this character speaks and somone hears it.
---@field private spacesPause boolean If true, pause self.rate ticks whenever spaces are encountered.
---@field private queue string The string of currently playing characters.
---@field private currentSound Sound The currently playing sound object.
---@field private speechCallback Speech.SpeechCallback A callback function that runs whenever a speech sound is played. Can be used for custom visualizers or other effects.
local Speech = {}
Speech.__index = Speech

---Creates a new speech object.
---@param o? table Optional table to initialize as the speech object.
---@return Speech speech The created speech object.
function Speech.new(o)
    o = o or {}
    setmetatable(o, Speech)
	o.sounds = {}
	o.rate = 1
	o.volume = 1
	o.basePitch = 1
	o.pitchRange = 0.25
	o.maxLength = SAFE_SPEECH_LENGTH
	o.polyphony = false
	o.subtitleVerb = 'speaks'
	o.spacesPause = true
	
	o.queue = nil
	o.currentSound = nil

	o.speechCallback = nil
    return o
end

---@alias SpeechSound string|Sound
---@alias SpeechSoundList [SpeechSound]
---@alias SpeechSoundMap table<string|number, SpeechSound|SpeechSoundList>

---Add one or more sounds as a string or Sound resource.
---
---String keys in mapping tables are treated as character groups.
---
--- Advanced mapping Example:
--- ```lua
--- { 
--- 	["aeiou"] = {"voices.vowel1", "voices.vowel2"}, -- Randomized vowel1/2 for all vowels
--- 	["!?"] = "click", -- "click" sound for both ! and ?
--- 	"fallback" -- fallback sound
--- }
--- ```
---
---@param sound SpeechSound|SpeechSoundList|SpeechSoundMap The sound resource(s) or sound path(s) to add.
---@return self
---@see sounds
---@see Sound
function Speech:addSound(sound)
	if type(sound) == 'string' then
		local s = sounds[sound]
		if type(s) ~= 'Sound' then error('BugSpeak: Sound "'..tostring(s)..'" is not a sound resource or string. (multi-sound addSound(...))') return self end
		sound = s
	end
	if type(sound) == 'Sound' then
		if not self.sounds[''] then self.sounds[''] = {} end
		self.sounds[''][#self.sounds['']+1] = sound
	end
	
	if type(sound) == 'table' then
		for key, s in pairs(sound) do
			if type(s) == 'string' then
				s = sounds[s]
			end
			if type(s) ~= 'Sound' then error('BugSpeak: Sound "'..tostring(s)..'" is not a sound resource or string. (multi-sound addSound(...))') return self end
			local chars = type(key) == 'string' and key:lower() or ''
			for c in chars:gmatch('.') do
				if not self.sounds[c] then self.sounds[c] = {} end
				self.sounds[c][#self.sounds[c]+1] = s
			end
			if chars == "" then
				if not self.sounds[''] then self.sounds[''] = {} end
				self.sounds[''][#self.sounds['']+1] = s
			end
		end
	end
	return self
end

local function isImmediateChild(name, prefix)
	prefix = prefix:gsub('%.+$', '')
	if prefix == '' then return select(2, name:gsub('%.', '')) == 0 end
	if name:sub(1, #prefix) ~= prefix then return false end
	local rest = name:sub(#prefix + 2)
	if rest == '' then return false end
	return not rest:find('%.')
end

---Add one or more sounds from the custom sound list using a `prefix`.
---@param prefix string The prefix to search for in the custom sound list.
---@param chars string? A string of characters to map the found sounds to. Each character in the string will be mapped to all found sounds. If nil or empty, maps found sounds to the generic "" key.
---@return self
---@see string.find
---@see sounds
---@see Sound
function Speech:addSounds(prefix, chars)
	-- remove trailing dots.
	prefix = prefix:gsub('%.+$', '')
	local found = {}
	for _, sound in ipairs(sounds:getCustomSounds()) do
		if isImmediateChild(sound, prefix) then
			found[#found+1] = sound
		end
	end
	self:addSound(chars and {[chars] = found} or found)
	return self
end

---Clears the sound queue.
---@return self
function Speech:clearQueue() self.queue = nil return self end
---Stops currently playing sound and clears the queue.
---@return self
function Speech:stop() self:clearQueue() if self.currentSound then self.currentSound:stop() self.currentSound = nil end return self end
---Clears all sounds.
---@return self
function Speech:clearSounds() self:stop() self.sounds = {} return self end
---Sets the speech rate.
---@param rate? integer (Optional) The speech rate in ticks. If nil, sets rate to 1. Minimum is 1.
---@return self
function Speech:setRate(rate) self.rate = math.max(rate or 1, 1) return self end
---Sets the speech volume.
---@param volume? number (Optional) The volume. If nil, sets volume to 1. Maximum is 1.
---@return self
function Speech:setVolume(volume) self.volume = math.max(math.min(volume or 1, 1), 0) return self end
---Sets the base pitch.
---@param basePitch? number (Optional) The base pitch. If nil, sets base pitch to 1. Minimum is 0.1.
---@return self
function Speech:setBasePitch(basePitch) self.basePitch = math.max(basePitch or 1, 0.1) return self end
---Sets the pitch range.
---@param pitchRange? number (Optional) The pitch range. If nil, sets pitch range to 0.25. Minimum is 0, no random pitch change.
---@return self
function Speech:setPitchRange(pitchRange) self.pitchRange = math.max(pitchRange or 0.25, 0) return self end
---Sets the maximum speech length.
---@param maxLength? number (Optional) The maximum speech length. If nil, defaults to SAFE_SPEECH_LENGTH (64).
---@return self
function Speech:setMaxLength(maxLength) self.maxLength = math.max(math.min(maxLength, SAFE_SPEECH_LENGTH) or SAFE_SPEECH_LENGTH, 1) return self end
---Sets the maximum speech length to 1, so only one character per message.
---@return self
---@see Speech.setMaxLength
function Speech:setOneShot() return self:setMaxLength(1) end
---Sets if polyphony is enabled.
---@param polyphony? boolean (Optional) Polyphony. If true, sounds can play on top of eachother. If false, only one sound can play at a time. If nil, disables polyphony.
---@return self
function Speech:setPolyphony(polyphony) self.polyphony = polyphony or false return self end
---Sets the subtitle verb for the sound. Default is 'speaks': '<Player Name> speaks'
---@param verb? string (Optional) The subtitle verb. If nil, disables subtitles.
---@return self
function Speech:setSubtitleVerb(verb) self.subtitleVerb = verb return self end
---Sets if the speech should pause on spaces.
---@param spacesPause? boolean (Optional) If true, pause for self.rate ticks whenever spaces are encountered. If false, ignore spaces. If nil, enables pausing.
---@return self
function Speech:setSpacesPause(spacesPause) self.spacesPause = spacesPause and spacesPause or false return self end
---Sets up a callback function that runs whenever a speech sound is played. Can be used for custom visualizers or other effects.
---@param callback Speech.SpeechCallback The callback function. It will be passed the character that was spoken and the sound that was played.
---@return self
function Speech:setCallback(callback) self.speechCallback = callback return self end
---Queues up speech blips to play.
---@param msg? string (Optional) The message to play. If nil, queues 1 blip.
---@return self
function Speech:play(msg)
	self.queue = (self.queue or '') .. (msg:lower() or '_'):sub(1,self.maxLength)
	return self
end


---Returns a randomized pitch for playing the speech sound.
---@return number pitch A randomized pitch from this speech object.
---@see Speech.basePitch
---@see Speech.pitchRange
---@private
function Speech:rollSpeechPitch()
	if (self.pitchRange or 0) > 0 then
		local basePitch = (self.basePitch or 1) - (self.pitchRange / 2)
		return basePitch + math.random() * self.pitchRange
	else
		return self.basePitch or 1
	end
end

---Plays a randomized speech sound.
---@param char string? (Optional) The character to play a sound for. If nil, plays a random sound from the generic list.
function Speech:playSpeechSound(char)
	if not self.polyphony and self.currentSound then
		self.currentSound:stop()
	end
	local list = self.sounds[char] or (self.sounds[''] or {})
	if not list or #list < 1 and char then return end
	self.currentSound = list[math.random(#list)]
		:pos(player:getPos())
		:volume(self.volume)
		:pitch(self:rollSpeechPitch())
		:subtitle(self.subtitleVerb and (player:getName()..' '..self.subtitleVerb) or nil)
		:play()
end

---The function that ticks this speech object.
function Speech:tick()
	if self.queue and #self.queue > 0 and world.getTime() % self.rate == 0 then
		local c = self.queue:sub(1,1)
		if c ~= ' ' or (not self.spacesPause) then
			self:playSpeechSound(c)
			if self.speechCallback then
				self.speechCallback(c)
			end
		end
		self.queue = self.queue:sub(2)
		if #self.queue == 0 then
			self.queue = nil
		end
	end
end

---Chat message event handler.
---@param msg string
---@return string msg
---@see events
function Speech:chat_send_message(msg)
	local m = msg
	if not self.sounds[''] or (#self.sounds[''] < 1 and #self.sounds == 1) then return msg end

	if msg:find('^/say ') then m = msg:sub(6) goto skip_cmd_check end
	if msg:find('^/') then return msg end
	::skip_cmd_check::
	if self.volume > 0 then
		pings.BugSpeak(m)
	end
	return msg
end

---@class BugSpeak
---@field Speech Speech Speech object definition.
---@field private INSTANCE Speech Currently registered speech instance.
---@field private RunLater RunLater KorboSpeak's local RunLater library.
local BugSpeak = {RunLater = RunLater, Speech = Speech, INSTANCE = nil}

---Sets a given speech object to the active one.
---@param speech Speech? The speech to activate. If nil, disables speech.
---@return Speech? speech The speech argument, or nil if not provided.
function BugSpeak:activate(speech)
	if  BugSpeak.INSTANCE and BugSpeak.INSTANCE ~= speech then
		BugSpeak.INSTANCE:clearQueue()
	end
	BugSpeak.INSTANCE = speech
	return speech
end

---Deactivates the current speech object.
---@return Speech deactivated The deactivated speech object, or nil if none exists.
function BugSpeak:deactivate()
	local deactivated = self:current()
	self:activate(nil)
	return deactivated
end

---Returns true if an active speech object exists.
---@return boolean speechEnabled Is there an active speech object?
function BugSpeak:active()
	return self:current() ~= nil
end

---Returns the current speech object.
---@return Speech speech The active speech object.
function BugSpeak:current()
	return BugSpeak.INSTANCE
end

---Creates a new speech objects AND activates it.
---@return Speech speech The new speech object.
function BugSpeak:new()
	return BugSpeak:activate(Speech.new())
end

--Register figura events--
events.TICK:register(BugSpeak.RunLater.tick)
events.TICK:register(function () if BugSpeak:active() then BugSpeak:current():tick() end end)

events.CHAT_SEND_MESSAGE:register(function(msg)
	if not msg then return end
	if BugSpeak:active() then return BugSpeak:current():chat_send_message(msg) end
	return msg
end)

--Register figura pings--
function pings.BugSpeak(msg)
	if BugSpeak:active() then BugSpeak:current():play(msg) end
end

return BugSpeak