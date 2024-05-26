local Input = {
  emitter = nil
}

function Input:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Input:init(emitter)
  self.emitter = emitter
end

function Input:get(k)
  return self[k]
end

function Input:set(k, v)
  self[k] = v
end

function Input:_emit(message)
  self.emitter:set(message)
end

return Input