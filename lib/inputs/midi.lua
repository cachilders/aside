local Input = include('lib/inputs/input')

local InputMidi = {
  connection = nil,
  type = 'midi'
}

setmetatable(InputMidi, {__index = Input})

function InputMidi:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function InputMidi:init(id, emitter, device)
  device.event = function(data)
    local e = midi.to_msg(data)
    if e.type == 'note_on' or e.type == 'note_off' then
      self:_emit({
        channel = e.ch,
        event = e.type,
        note = e.note,
        type = self.type,
        velocity = e.vel,
        volts = e.note / 12
      })
    end
  end

  self.connection = device
  self.emitter = emitter
  self.id = id
end

return InputMidi
