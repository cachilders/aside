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
  c:init(1, emitter)
  
  self.list = {c}

  for i = 1, #connections do
    local m = InputMidi:new()
    m:init(i + 1, emitter, connections[i])
    table.insert(self.list, m)
  end
end

function Inputs:at(k)
  return self.list[k]
end

return Inputs