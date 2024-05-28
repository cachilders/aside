local Parameters = {
  crow_present = false,
  destination_names = nil,
  destinations = nil,
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
  self:_init_device_params()
  self:_init_lfo_params(lfos)
  params:bang()
end

function Parameters:refresh(lfos)
  -- TODO
  params:bang()
end

function Parameters:get(k)
  return self[k]
end

function Parameters:_fetch_device_state()
  local destination_names = {}
  local destinations = {{name = 'Omni', port = nil}}
  self.crow_present = norns.crow.dev ~= nil
  self:_enumerate_midi_devices()

  if self.crow_present then
    destinations[2] = {name = 'Crow', port = 0}
  end

  for i = 1, #self.midi_devices do
    table.insert(destinations, self.midi_devices[i])
  end

  for i = 1, #destinations do
    destination_names[i] = self._truncate_string(destinations[i].name, 12)
  end

  self.destination_names = destination_names
  self.destinations = destinations
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

function Parameters:_init_device_params()
  local device_count = #self.destinations - 1
  params:add_group('devices', 'Toggle Sources', device_count)

  if self.crow_present then
    params:add_binary('crow_toggle', 'Echo on Crow', 'toggle', 1)
  end

  for i = 1, #self.midi_devices do
    local device = self.midi_devices[i]
    local name = self._truncate_string(device.name, 16)
    params:add_binary('midi_'..device.port..'_toggle', 'Echo on '..name, 'toggle', 1)
  end

  params:add_group('routes', 'Echo Routing', device_count)
  for i = 2, #self.destinations do
    local name = self.destination_names[i]
    local label = i..name..'_route'
    params:add_option(label, name..' ->', self.destination_names, i)
  end
end

function Parameters:_init_lfo_params(lfos)
  if self.crow_present then
    lfos[1].instance:add_params('crow_lfo', 'LFO 0 > CV Echo', 'LFO > CV Echo')
  end

  for i = 1, #self.midi_devices do
    local device = self.midi_devices[i]
    local name = self._truncate_string(device.name, 15)
    lfos[i + 1].instance:add_params('midi_'..device.port..'_lfo', 'LFO '..i..'> '..name..' Echo', 'LFO > '..name..' Echo')
  end
end

function Parameters:_init_static_params()
  params:add_separator('app_name_spacer', '')
  params:add_separator('app_name', 'Magpie')
end

function Parameters:_refresh_lfo_params(lfos)
  -- TODO init all lfo params and show or hide based on config?
end

return Parameters