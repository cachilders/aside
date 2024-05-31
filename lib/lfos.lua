local LFO = require('lfo')
local Lfo = include('lib/lfos/lfo')
local lfo_count = 17 -- 1 CV Input + 16 MIDI Inputs

local Lfos = {
  list = nil
}

function Lfos:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Lfos:init()
  local oscillators = {}

  for i = 1, lfo_count do
    local osc = Lfo:new()
    osc:init(LFO, i)
    osc:start()
    table.insert(oscillators, osc)
  end

  self.list = oscillators
end

function Lfos:get(k)
  return self[k]
end

function Lfos:poll(i)
  return {
    mode = self.list[i]:get('mode'),
    period = self.list[i]:get('period'), -- seconds
    value = self.list[i]:get('scaled') -- 0..1.0
  }
end

return Lfos