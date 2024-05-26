local Input = include('lib/inputs/input')

local InputMidi = {
  connection = nil
}

setmetatable(InputMidi, {__index = Input})

function InputMidi:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function InputMidi:init(emitter)
  self.emitter = emitter
  self.connection = midi.connect()
  self.connection.event = function(data)
    local e = midi.to_msg(data)
    if e.type == 'note_on' or e.type == 'note_off' then
      self:_emit({
        channel = e.ch,
        event = e.type,
        note = e.note,
        type = 'midi',
        velocity = e.vel
      })
    end
  end
end

return InputMidi
