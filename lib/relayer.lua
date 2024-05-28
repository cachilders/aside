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
  if output:get('type') == 'cv' then message.channel = 2 end
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
    local echo = {
      channel = message.channel,
      event = message.event,
      note = message.note,
      type = message.type,
      velocity = message.velocity * lfo_state.value,
      volts = message.volts
    }
    local route = params:get(input_name..'_route')

    if lfo_state.mode == 'free' then
      delay = lfo_state.period
    else
      delay = (60 / params:get('clock_tempo')) * lfo_state.period
    end

    if route == 1 then -- 1 is 'Omni' routing to all devices
      for i = 1, #outputs:get('list') do
        self:delay(delay, echo, outputs:at(i))
      end
    else
      self:delay(delay, echo, outputs:at(route - 1))
    end
  end
end

return Relayer