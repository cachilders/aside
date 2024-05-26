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

function Inputs:init(emitter)
  self.emitter = emitter
  self.list = {
    InputCrow:new(),
    InputMidi:new()
  }

  for i = 1, #self.list do
   self.list[i]:init(emitter)
  end
end

function Inputs:get(k)
  return self[k]
end

function Inputs:set(k, v)
  self[k] = v
end

return Inputs