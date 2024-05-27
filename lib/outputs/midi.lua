local Output = include('lib/outputs/output')

local OutputMidi = {
  connection = nil
}

setmetatable(OutputMidi, {__index = Output})

function OutputMidi:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function OutputMidi:init(emitter, device)
  self.connection = device
  self.emitter = emitter
end

function OutputMidi:note_on(message)
  self.connection:note_on(message.note, message.velocity, message.channel)
  self:_emit(message)
end

function OutputMidi:note_off(message)
  self.connection:note_off(message.note, message.velocity, message.channel)
  self:_emit(message)
end

return OutputMidi