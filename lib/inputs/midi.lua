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

function InputMidi:init(id, emitter, device)
  device.event = function(data)
    local e = midi.to_msg(data)
    if e.type == 'note_on' or e.type == 'note_off' then
      self:_emit({
        channel = e.ch,
        event = e.type,
        note = e.note,
        type = 'midi',
        velocity = e.vel,
        volts = musicutil.note_num_to_freq(e.note) -- TODO scale to make sense
      })
    end
  end

  self.connection = device
  self.emitter = emitter
  self.id = id
end

return InputMidi
