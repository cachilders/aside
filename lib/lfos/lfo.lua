local Lfo = {
  id = nil,
  instance = nil,
  value = nil
}

function Lfo:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Lfo:init(lfo_lib, id)
  self.id = id
  self.instance = lfo_lib:add{
    max = 1,
    min = 0,
    depth = 1,
    mode = 'free',
    period = 1
  }
end

function Lfo:set(k, v)
  self.instance:set(k, v)
end

function Lfo:get(k)
  return self.instance:get(k)
end

function Lfo:start()
  self.instance:start()
end

function Lfo:stop()
  self.instance:stop()
end

return Lfo