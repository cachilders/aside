local Input = include('lib/inputs/input')

local MidiInput = {}

setmetatable(MidiInput, {__index = Input})

function MidiInput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MidiInput:init(emitter)
  self.emitter = emitter
  -- TODO connect input streams to emitter
  -- midi note events 
  -- may need to do dirty if no event is possible
end

return MidiInput
