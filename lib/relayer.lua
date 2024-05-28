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

function Relayer:process(message, output, lfo_state)
  self.relay(message, output)

  local echo = {
    channel = message.type == 'cv' and 2 or message.channel,
    event = message.event,
    note = message.note,
    type = message.type,
    velocity = message.velocity * lfo_state.value,
    volts = message.volts
  }

  self:delay(lfo_state.period, echo, output)
end

return Relayer