local Input = {
  emitter = nil,
  id = nil,
  type = nil
}

function Input:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Input:init(id, emitter)
  self.emitter = emitter
end

function Input:get(k)
  return self[k]
end

function Input:set(k, v)
  self[k] = v
end

function Input:_emit(message)
  message.origin = 'input'
  self.emitter:set({message, self.id})
end

return Input