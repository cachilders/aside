local Output = {
  emitter = nil,
  id = nil
}

function Output:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Output:init(id, emitter)
  self.emitter = emitter
  self.id = id
end

function Output:get(k)
  return self[k]
end

function Output:note_on(message)
  print(message)
  self:_emit(message)
end

function Output:note_off(message)
  print(message)
  self:_emit(message)
end

function Output:receive(message)
  if message.event == 'note_on' then
    self:note_on(message)
  elseif message.event == 'note_off' then
    self:note_off(message)
  end
end

function Output:_emit(message)
  message.origin = 'output'
  self.emitter:set(message)
end

return Output