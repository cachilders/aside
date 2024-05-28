local Parameters = {
  crow_present = false,
  midi_devices = nil
}

function Parameters._truncate_string(s, l)
  if string.len(s) > l then
    return ''..string.sub(s, 1, l-1)..'...'
  end
  return s
end

function Parameters:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Parameters:init(lfos)
  self:_init_static_params()
  self:_fetch_device_state()
  self:_init_lfo_params(lfos)
end

function Parameters:refresh(lfos)
  -- TODO
end

function Parameters:_fetch_device_state()
  self.crow_present = norns.crow.dev ~= nil
  self:_enumerate_midi_devices()
end

function Parameters:_enumerate_midi_devices()
  local devices = {}

  for i = 1, #midi.vports do
    if midi.vports[i].name ~= 'none' then
      local device = midi.vports[i].device
      devices[i] = {name = device.name, port = device.port}
    end
  end

  self.midi_devices = devices
end

function Parameters:_init_lfo_params(lfos)
  if self.crow_present then
    lfos[1].instance:add_params('crow_lfo', 'CV Echo LFO', 'CV Echo LFO')
  end

  for i = 1, #self.midi_devices do
    local device = self.midi_devices[i]
    local name = self._truncate_string(device.name, 12)
    lfos[device.port].instance:add_params('midi_'..device.port..'_lfo', device.port..'. '..name..' Echo LFO', device.port..'. '..name..' Echo LFO')
  end
end

function Parameters:_refresh_lfo_params(lfos)
  -- TODO init all lfo params and show or hide based on config?
end

function Parameters:_init_static_params()
  params:add_separator('app_name', 'Magpie')
end

return Parameters