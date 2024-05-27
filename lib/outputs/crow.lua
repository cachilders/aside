local Output = include('lib/outputs/output')

local OutputCrow = {
  gate_port = nil,
  volts_port = nil
}

setmetatable(OutputCrow, {__index = Output})

function OutputCrow:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function OutputCrow:init(emitter, n)
  self.volts_port = n
  self.gate_port = n + 1
  self.emitter = emitter
end

function OutputCrow:note_on(message)
  crow.output[self.gate_port].volts = 5
  crow.output[self.volts_port].volts = message.volts
  self:_emit(message)
end

function OutputCrow:note_off(message)
  crow.output[self.gate_port].volts = 0
  self:_emit(message)
end

return OutputCrow