-- Aside
-- modulated note echo for midi and crow


local Inputs = include('lib/inputs')

local emitters = {}
local observable = require('container.observable')
local shift = false

local function get_time()
  local bpm = 60 / params:get('clock_tempo')
end

local function init_inputs()
  emitters.input = observable.new()
  local inputs = Inputs:new()
  inputs:init(emitters.input)
end

function init()
  init_inputs()
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

  -- TEMP INPUT FEEDBACK

  screen.move(1, 1)
  screen.text('TEST')

  --

  screen.update()
end

function refresh()
  redraw()
end