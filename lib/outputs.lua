local OutputCrow = include('lib/outputs/crow')
local OutputMidi = include('lib/outputs/midi')

local Outputs = {
  list = nil
}

function Outputs:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Outputs:init(emitter, connections)
  local c = OutputCrow:new()
  c:init(1, emitter)

  local outputs = {c}

  for i = 1, #connections do
    local m = OutputMidi:new()
    m:init(i + 1, emitter, connections[i])
    table.insert(outputs, m)
  end

  self.list = outputs
end

function Outputs:at(k)
  return self.list[k]
end

return Outputs