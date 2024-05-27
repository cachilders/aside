local Output = {
  emitter
}

function Output:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Output:init(emitter)
  self.emitter = emitter
end

function Output:note_on(message)
  print(message)
  self:_emit(message)
end

function Output:note_off(message)
  print(message)
  self:_emit(message)
end

function Output:_emit(message)
  message.origin = 'output'
  self.emitter:set(message)
end

return Output