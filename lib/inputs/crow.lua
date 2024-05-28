local Input = include('lib/inputs/input')

local InputCrow = {
  volts = nil
}

setmetatable(InputCrow, {__index = Input})

function InputCrow:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function InputCrow:init(id, emitter)
  self.emitter = emitter
  self.id = id
  crow.input[1].stream = function(v) self.volts = v end
  crow.input[2].change = function(gate)
    self:_emit({
      channel = 1,
      event = gate and 'note_on' or 'note_off',
      note = musicutil.freq_to_note_num(self.volts), -- TODO Scale to midi voltage
      type = 'cv',
      velocity = gate and 127 or 0,
      volts = self.volts
    }) 
  end
  crow.input[1].mode('stream')
  crow.input[2].mode('change')
end

return InputCrow
