local ASSET_PATH = '/home/we/dust/code/magpie/assets/ui/'
local EXT = '.ext'
local BACKGROUND = 'background'
local ECHO_BIRD = 'echo_bird'
local ECHO_NOTE = 'echo_note'
local FOREGROUND = 'foreground'
local PRIME_BIRD = 'prime_bird'
local PRIME_NOTE = 'prime_note'

local Display = {}

function Display:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Display:init(emitters)
  local function init_subscribers()
    emitters.output:register('display_listener', function(message) self:_sing(message) end)
  end
end

function Display:render()
  screen.display_png(ASSET_PATH..BACKGROUND..EXT, 0, 0)
end

function Display:_call()
end

function Display:_respond()
end

function Display:_sing(message)
  if message.origin == 'prime' then
    self:_call()
  else
    self:_respond()
  end
end

return Display