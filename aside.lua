-- Aside
-- modulated note echo for midi and crow

musicutil = require('musicutil')

local Inputs = include('lib/inputs')
local Lfos = include('lib/lfos')
local Outputs = include('lib/outputs')
local Parameters = include('lib/parameters')
local Relayer = include('lib/relayer')

local emitters = nil
local inputs = nil
local lfos = nil
local midi_connections = nil
local observable = require('container.observable')
local outputs = nil
local relayer = nil
local shift = false

-- TEMP
local test_message = {}
--

local function get_time()
  local bpm = 60 / params:get('clock_tempo')
  return bpm
end

local function init_emitters()
  emitters = {
    bpm = observable.new(get_time())
  }
end

local function init_inputs()
  emitters.input = observable.new()
  inputs = Inputs:new()
  inputs:init(emitters.input, midi_connections)
end

local function init_lfos()
  lfos = Lfos:new()
  lfos:init()
end

local function init_midi()
  midi_connections = {
    midi.connect()  -- TODO: init all possible devices
  }
end

local function init_outputs()
  emitters.output = observable.new()
  outputs = Outputs:new()
  outputs:init(emitters.output, midi_connections)
end

local function init_parameters()
  Parameters.init()
end

local function init_relayer()
  relayer = Relayer:new()
end

local function init_subscribers()
  emitters.input:register('relayer_process', function(e)
    local message = e[1]
    local input_id = e[2]
    local lfo_state = lfos:poll(input_id)
    relayer:process(message, outputs:at(input_id), lfo_state)
  end)
  emitters.output:register('output_test', function(message) test_message = message end)
end

function init()
  init_parameters()
  init_midi()
  init_emitters()
  init_inputs()
  init_lfos()
  init_outputs()
  init_relayer()
  init_subscribers()
end

function enc(e, d)
end

function key(k, z)
  if k == 1 then
    if z == 1 then
      shift = true
    else
      shift = false
    end
  end
end

function redraw()
  screen.clear()

  if test_message.type then
    local count = 1
    for k, v in pairs(test_message) do
      screen.move(1, count * 10)
      screen.text(k..' = '..tostring(v))
      count = count + 1
    end
  else
    screen.move(1, 10)
    screen.text('Test')
  end

  screen.update()
end

function refresh()
  redraw()
end