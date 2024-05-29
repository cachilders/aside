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
  local echo_route = params:get(input_name..'_echo_route')
  local prime_route = params:get(input_name..'_prime_route')

  self:_route_primary(prime_route, message, outputs)

  if params:get(input_name..'_toggle') == 1 then
    local echo = {
      channel = message.channel,
      event = message.event,
      note = message.note,
      type = message.type,
      velocity = message.velocity * lfo_state.value,
      volts = message.volts
    }

    delay = self:_calculate_delay(lfo_state)
    self:_route_delay(delay, echo_route, echo, outputs)
  end
end

function Relayer:_calculate_delay(lfo_state)
  if lfo_state.mode == 'free' then
    return lfo_state.period
  else
    return (60 / params:get('clock_tempo')) * lfo_state.period
  end
end

function Relayer:_route_delay(delay, route, message, outputs)
  if route == 1 then -- 1 is 'Omni' routing to all devices
    for i = 1, #outputs:get('list') do
      self:delay(delay, message, outputs:at(i))
    end
  else
    self:delay(delay, message, outputs:at(route - 1))
  end
end

function Relayer:_route_primary(route, message, outputs)
  if route == 1 then -- 1 is 'Omni' routing to all devices
    for i = 1, #outputs:get('list') do
      self.relay(message, outputs:at(i))
    end
  else
    self.relay(message, outputs:at(route - 1))
  end
end

return Relayer