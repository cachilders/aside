local Output = include('lib/outputs/output')
local velocity_mod = 10/127

local OutputCrow = {
  type = 'cv'
}

setmetatable(OutputCrow, {__index = Output})

function OutputCrow:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function OutputCrow:init(id, emitter)
  self.emitter = emitter
  self.id = id
end

function OutputCrow:note_on(message)
  local ports = message.channel == 1 and {1, 2} or {3, 4}
  crow.output[ports[2]].volts = message.velocity * velocity_mod
  crow.output[ports[1]].volts = message.volts
  self:_emit(message)
end

function OutputCrow:note_off(message)
  local ports = message.channel == 1 and {1, 2} or {3, 4}
  crow.output[ports[2]].volts = message.velocity
  self:_emit(message)
end

return OutputCrow