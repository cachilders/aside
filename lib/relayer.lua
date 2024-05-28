local Relayer = {}

function Relayer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Relayer.relay(message, output)
  output:receive(message)
end

function Relayer:delay(s, message, output)
  clock.run(
    function()
      clock.sleep(s)
      self.relay(message, output)
    end
  )
end

function Relayer:process(message, input_id, lfo_state, destinations, outputs)
  local delay, input_name = nil, destinations[input_id + 1].name
  self.relay(message, outputs:at(input_id))

  if params:get(input_name..'_toggle') == 1 then
    if lfo_state.mode == 'free' then
      delay = lfo_state.period
    else
      delay = (60 / params:get('clock_tempo')) * lfo_state.period
    end
  
    local echo = {
      channel = message.type == 'cv' and 2 or message.channel,
      event = message.event,
      note = message.note,
      type = message.type,
      velocity = message.velocity * lfo_state.value,
      volts = message.volts
    }
  
    self:delay(delay, echo, outputs:at(input_id))
  end
end

return Relayer