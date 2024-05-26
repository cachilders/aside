local Input = include('lib/inputs/input')

local CrowInput = {}

setmetatable(CrowInput, {__index = Input})

function CrowInput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CrowInput:init(emitter)
  self.emitter = emitter
  -- TODO connect input streams to emitter
  -- crow.input[i]:get('source').mode('stream', time_arg)
  -- may need to do dirty if no event is possible
end

return CrowInput
