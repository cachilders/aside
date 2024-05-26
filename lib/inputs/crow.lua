local Input = include('lib/inputs/input')

local InputCrow = {
  signal = nil
}

setmetatable(InputCrow, {__index = Input})

function InputCrow:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function InputCrow:init(emitter)
  self.emitter = emitter
  crow.input[1].stream = function(v) self.signal = v end
  crow.input[2].change = function(v)
    self:_emit({
      gate = v,
      signal = self.signal,
      type = 'cv'
    }) 
  end
  crow.input[1].mode('stream')
  crow.input[2].mode('change')
end

return InputCrow
