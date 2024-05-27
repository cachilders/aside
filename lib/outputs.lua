local OutputCrow = include('lib/outputs/crow')
local OutputMidi = include('lib/outputs/midi')

local Outputs = {
  crow = nil,
  midi = nil
}

function Outputs:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Outputs:init(emitter, connections)
  local midis = {}
  local murder = {}
  for i = 1, 3, 2 do
    local c = OutputCrow:new()
    c:init(emitter, i)
    table.insert(murder, c)
  end

  for i = 1, #connections do
    local m = OutputMidi:new()
    m:init(emitter, connections[i])
    table.insert(midis, m)
  end

  self.crow = murder
  self.midi = midis
end

function Outputs:get(k)
  return self[k]
end

function Outputs:set(k, v)
  self[k] = v
end

return Outputs