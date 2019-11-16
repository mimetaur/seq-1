-- seq-1
-- an SQ-1 for norns
--

local UI = require "ui"
local Sequence = include("lib/sequence")

local pages, sequences
local NUM_SEQUENCES = 2

local function on_input_one_change()
	local output = {}
	local gate, cv = sequences[pages.index]:advance()
	if cv then
		crow.output[1].volts = cv
	end
	if gate then
		crow.output[2].execute()
	end
end

function init()
	pages = UI.Pages.new(1, 2)

	sequences = {}
	for i = 1, NUM_SEQUENCES do
		sequences[i] = Sequence.new(i)
	end

	crow.ii.pullup(true)
	-- crow input 1 is a clock requiring triggers
	crow.input[1].mode("change", 1, 0.1, "rising")
	crow.input[1].change = on_input_one_change

	-- crow input 2 is a reset requiring a trigger
	crow.input[2].mode("change", 1, 0.1, "rising")

	-- crow output 1 and 3 are cv
	crow.output[1].slew = 0
	crow.output[1].volts = 0

	crow.output[3].slew = 0
	crow.output[3].volts = 0

	-- crow output 2 and 4 are gates/triggers
	crow.output[2].slew = 0
	crow.output[2].action = "pulse(0.1,5,1)"
	crow.output[4].slew = 0
	crow.output[4].action = "pulse(0.1,5,1)"
end

function enc(n, delta)
	if n == 1 then
		pages:set_index_delta(delta, false)
		sequences[pages.index]:update()
	elseif n == 2 then
		sequences[pages.index]:select_step_by_delta(delta)
		sequences[pages.index]:update()
	elseif n == 3 then
		sequences[pages.index]:set_selected_step_value_by_delta(delta)
	end
	redraw()
end

function key(n, z)
	if n == 2 and z == 1 then
		sequences[pages.index]:toggle_selected_step()
	elseif n == 3 and z == 1 then
		-- this is temporary
		-- (for testing sequencer without crow)
		on_input_one_change()
	end
	redraw()
end

function redraw()
	screen.clear()
	pages:redraw()
	sequences[pages.index]:draw()
	screen.update()
end
