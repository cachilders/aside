local ASSET_PATH = '/home/we/dust/code/magpie/assets/ui/'
local EXT = '.png'
local BACKGROUND = 'background'
local ECHO_BIRD = 'echo_bird'
local ECHO_NOTE = 'echo_note'
local FOREGROUND = 'foreground'
local PRIME_BIRD = 'prime_bird'
local PRIME_NOTE = 'prime_note'

local Display = {
  call_timer = nil,
  calling = false,
  responding = false,
  response_timer = false
}

function Display:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Display:init(emitters)
  emitters.output:register('display_listener', function(message) self:_sing(message) end)
end

function Display:render()
  screen.display_png(ASSET_PATH..BACKGROUND..EXT, 0, 0)
  screen.display_png(ASSET_PATH..ECHO_BIRD..EXT, 92, 13)
  screen.display_png(ASSET_PATH..PRIME_BIRD..EXT, 11, 23)
  screen.display_png(ASSET_PATH..FOREGROUND..EXT, 0, 0)

  if self.calling == true then
    screen.display_png(ASSET_PATH..PRIME_NOTE..EXT, 53, 17)
  end

  if self.responding == true then
    screen.display_png(ASSET_PATH..ECHO_NOTE..EXT, 79, 7)
  end
end

function Display:_call(delay, note_on)
  if self.call_timer then
    clock.cancel(self.call_timer)
    self.call_timer = nil
    self.calling = false
  end

  if note_on then
    self.calling = true
    self.call_timer = clock.run(function()
      clock.sleep(delay * 0.5)
      self.calling = false
    end)
  end
end

function Display:_respond(delay, note_on)
  if self.response_timer then
    clock.cancel(self.response_timer)
    self.response_timer = nil
    self.responding = false
  end

  if note_on then
    self.responding = true
    self.response_timer = clock.run(function()
      clock.sleep(delay * 0.5)
      self.responding = false
    end)
  end
end

function Display:_sing(message)
  local delay, note_on = message.delay, message.event == 'note_on'

  if message.echo and message.velocity > 0 then
    self:_respond(delay, note_on)
  else
    self:_call(delay, note_on)
  end
end

return Display