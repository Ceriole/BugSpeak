---BugSpeak v0.1.1 by @ceriole
---Loosely based upon KorboSpeak by @korbosoft

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
    local is_delay= type(ticks) =="number"
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

---Speech object.
---@class Speech
---@field sounds [Sound] A list of sound resources. Use mono channel sounds, otherwise they will be heard globally!
---@field rate number Rate of speech, how many ticks to wait per speech sound.
---@field volume number Volume of speech sound.
---@field basePitch number The base pitch to start at. nil = 1.0
---@field pitchRange number Range of pitch randomization. Zero or nil disables random pitch.
---@field maxLength number Maximum amount of text characters to speak.
---@field polyphony boolean Set to true if you want speech sounds to overlap.
---@field subtitleVerb string The subtitle to display when this character speaks and somone hears it.
---@field spacesPause boolean If true, pause self.rate ticks whenever spaces are encountered.
---@field private queue string The string of currently playing characters.
---@field private currentSound Sound The currently playing sound object.
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
	o.maxLength = math.huge
	o.polyphony = false
	o.subtitleVerb = 'speaks'
	o.spacesPause = true

	o.queue = nil
	o.currentSound = nil
    return o
end

---Add one or more sounds as a string or Sound resource.
---@param sound string|Sound|[string|Sound] The sound resource(s) or sound path(s) to add.
---@return self
---@see sounds
---@see Sound
function Speech:addSound(sound)
	if type(sound) == 'table' then
		for _,s in ipairs(sound) do
			self:addSound(s)
		end
	elseif type(sound) == 'Sound' then
		self.sounds[#self.sounds+1] = sound
	elseif type(sound) == 'string' then
		if sound and sounds:isPresent(sound) then
			self.sounds[#self.sounds+1] = sounds[sound]
		else
			error('BugSpeak: Sound "'..tostring(sound)..'" does not exist.')
		end
	else
		error('BugSpeak: Sound is nil or is not a sound resource or string.')
	end
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
---@param rate? number (Optional) The speech rate in ticks. If nil, sets rate to 1.
---@return self
function Speech:setRate(rate) self.rate = math.max(rate or 1, 1) return self end
---Sets the speech volume.
---@param volume? number (Optional) The volume. If nil, sets volume to 1.
---@return self
function Speech:setVolume(volume) self.volume = math.max(volume or 1, 0) return self end
---Sets the base pitch.
---@param basePitch? number (Optional) The base pitch. If nil, sets base pitch to 1.
---@return self
function Speech:setBasePitch(basePitch) self.basePitch = math.max(basePitch or 1, 0.1) return self end
---Sets the pitch range.
---@param pitchRange? number (Optional) The pitch range. If nil, sets pitch range to 0.25.
---@return self
function Speech:setPitchRange(pitchRange) self.pitchRange = math.max(pitchRange or 0.25, 0) return self end
---Sets the maximum speech length.
---@param maxLength? number (Optional) The maximum speech length. If nil, disables maximum length.
---@return self
function Speech:setMaxLength(maxLength) self.maxLength = math.max(maxLength or math.huge, 1) return self end
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
---Queues up speech blips to play.
---@param msg? string (Optional) The message to play. If nil, queues 1 blip.
---@return self
function Speech:play(msg)
	self.queue = (self.queue or '') .. (msg or '_'):sub(1,self.maxLength)
	return self
end

---Returns the base pitch of the speech sound. If
---@return number basePitch The base pitch of this speech object.
---@see Speech.basePitch
---@see Speech.pitchRange
---@private
function Speech:getSpeechPitch()
	if (self.pitchRange or 0) > 0 then
		local basePitch = (self.basePitch or 1) - (self.pitchRange / 2)
		return basePitch + math.random() * self.pitchRange
	else
		return self.basePitch or 1
	end
end

---Plays a randomized speech sound.
function Speech:playSpeechSound()
	if not self.polyphony and self.currentSound then
		self.currentSound:stop()
	end
	self.currentSound = self.sounds[math.random(#self.sounds)]
		:pos(player:getPos())
		:volume(self.volume)
		:pitch(self:getSpeechPitch())
		:subtitle((player:getName()..' '..self.subtitleVerb) and self.subtitleVerb or nil)
		:play()
end

---The function that ticks this speech object.
function Speech:tick()
	if self.queue and #self.queue > 0 and world.getTime() % self.rate == 0 then
		local c = self.queue:sub(1,1)
		if c ~= ' ' or (not self.spacesPause) then self:playSpeechSound() end
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
	if #self.sounds < 1 then return msg end
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