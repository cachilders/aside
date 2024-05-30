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
  local echo_channel = params:get(input_name..'_echo_channel_midi')
  local echo_route = params:get(input_name..'_echo_route')
  local echo_destination_name = destinations[echo_route].name
  local prime_channel = params:get(input_name..'_prime_channel_midi')
  local prime_route = params:get(input_name..'_prime_route')
  local prime_destination_name = destinations[prime_route].name

  if prime_destination_name == 'Crow' then
    prime_channel = params:get(input_name..'_prime_channel_crow')
  elseif prime_channel == 1 then
    prime_channel = message.channel
  else
    prime_channel = prime_channel - 1 -- 1 defaults to origin channel
  end
  
  local prime = {
    channel = prime_channel,
    event = message.event,
    note = message.note,
    type = message.type,
    velocity = message.velocity * lfo_state.value,
    volts = message.volts
  }

  self:_route_primary(prime_route, prime, outputs)

  if params:get(input_name..'_toggle') == 1 then
    if prime_destination_name == 'Crow' then
      echo_channel = params:get(input_name..'_echo_channel_crow')
    elseif echo_channel == 1 then
      echo_channel = message.channel
    else
      echo_channel = echo_channel - 1 -- 1 defaults to origin channel
    end

    local echo = {
      channel = echo_channel,
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