local Parameters = {
  crow_channel_options = {'1/2', '3/4'},
  crow_present = false,
  destination_names = nil,
  destinations = nil,
  midi_channel_options = nil
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

function Parameters:init(lfos, midi_devices, midi_panic)
  self:_init_static_params(midi_panic)
  self:_fetch_device_state(midi_devices)
  self:_init_device_params()
  self:_init_lfo_params(lfos, midi_devices)
  params:bang()
end

function Parameters:refresh(lfos)
  self:_refresh_lfo_params()
  self:_refresh_route_params()
  -- params:bang()
end

function Parameters:get(k)
  return self[k]
end

function Parameters:_fetch_device_state(midi_devices)
  local destination_names = {}
  local destinations = {{name = 'Omni', port = nil}}
  self.crow_present = norns.crow.dev ~= nil
  self:_enumerate_midi_devices()

  if self.crow_present then
    destinations[2] = {name = 'Crow', port = 0}
  end

  for i = 1, #midi_devices do
    table.insert(destinations, midi_devices[i])
  end

  for i = 1, #destinations do
    destination_names[i] = self._truncate_string(destinations[i].name, 12)
  end

  self.destination_names = destination_names
  self.destinations = destinations
end

function Parameters:_enumerate_midi_devices(midi_devices)
  local devices = {}

  for i = 1, #midi.vports do
    if midi.vports[i].name ~= 'none' then
      local device = midi.vports[i].device
      if device then 
        devices[i] = {name = device.name, port = device.port}
      end
    end
  end

  midi_devices = devices
end

function Parameters:_init_device_params()
  local midi_channel_options = {'Origin'}
  local device_count = #self.destinations - 1

  for i = 1, 16 do
    table.insert(midi_channel_options, i)
  end

  self.midi_channel_options = midi_channel_options

  params:add_group('devices', 'Toggle Sources', device_count)
  for i = 2, #self.destinations do
    local device = self.destinations[i]
    local name = self._truncate_string(device.name, 16)
    params:add_binary(device.name..'_toggle', 'Echo on '..name, 'toggle', 1)
  end

  params:add_group('prime_routes', 'Primary Routing', device_count * 3)
  for i = 2, #self.destinations do
    local device = self.destinations[i]
    local name = self.destination_names[i]
    params:add_option(device.name..'_prime_route', name..' ->', self.destination_names, i)
    -- params:set_action(device.name..'_prime_route', function() self:refresh() end)
    params:add_option(device.name..'_prime_channel_crow', '  `-> Outlet Channel', self.crow_channel_options, 1)
    params:add_option(device.name..'_prime_channel_midi', '  `-> Outlet Channel', self.midi_channel_options, 1)
  end

  params:add_group('echo_routes', 'Echo Routing', device_count * 3)
  for i = 2, #self.destinations do
    local channel_options, default_option
    local device = self.destinations[i]
    local name = self.destination_names[i]

    params:add_option(device.name..'_echo_route', name..' ->', self.destination_names, i)
    -- params:set_action(device.name..'_echo_route', function() self:refresh() end)
    params:add_option(device.name..'_echo_channel_crow', '  `-> Outlet Channel', self.crow_channel_options, 2)
    params:add_option(device.name..'_echo_channel_midi', '  `-> Outlet Channel', self.midi_channel_options, 1)
  end

  self:refresh()
end

function Parameters:_init_lfo_params(lfos, midi_devices)
  if self.crow_present then
    lfos[1].instance:add_params('crow_lfo', 'LFO 0 > CV Echo', 'LFO > CV Echo')
  end

  for i = 1, #midi_devices do
    local device = midi_devices[i]
    if device then
      local name = self._truncate_string(device.name, 15)
      lfos[i + 1].instance:add_params('midi_'..device.port..'_lfo', 'LFO '..i..'> '..name..' Echo', 'LFO > '..name..' Echo')
    end
  end
end

function Parameters:_init_static_params(midi_panic)
  params:add_separator('app_name_spacer', '')
  params:add_separator('app_name', 'Magpie')
  params:add_trigger('midi_panic', 'MIDI Panic')
  params:set_action('midi_panic', midi_panic)
end

function Parameters:_refresh_lfo_params(lfos)
  -- TODO init all lfo params and show or hide based on config?
end

function Parameters:_refresh_route_params()
  for i = 2, #self.destinations do
    local device_name = self.destinations[i].name
    local prime_route_name = params:get(device_name..'_prime_route')
    local echo_route_name = params:get(device_name..'_echo_route')

    if prime_route_name == 'Crow' then
      params:show(device_name..'_prime_channel_crow')
      params:hide(device_name..'_prime_channel_midi')
    else
      params:hide(device_name..'_prime_channel_crow')
      params:show(device_name..'_prime_channel_midi')
    end

    if echo_route_name == 'Crow' then
      params:show(device_name..'_echo_channel_crow')
      params:hide(device_name..'_echo_channel_midi')
    else
      params:hide(device_name..'_echo_channel_crow')
      params:show(device_name..'_echo_channel_midi')
    end
  end
end

return Parameters