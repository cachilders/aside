local InputCrow = include('lib/inputs/crow')
local InputMidi = include('lib/inputs/midi')

local Inputs = {
  list = nil
}

function Inputs:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Inputs:init(emitter, connections)
  local c = InputCrow:new()
  c:init(emitter)
  
  self.list = {c}

  for i = 1, #connections do
    local m = InputMidi:new()
    m:init(emitter, connections[i])
    table.insert(self.list, m)
  end
end

function Inputs:get(k)
  return self[k]
end

function Inputs:set(k, v)
  self[k] = v
end

return Inputs