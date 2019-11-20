-- seq-1
-- an SQ-1 for norns
--
-- ENC1 selects a sequence
-- ENC2 selects a step
-- ENC3 changes step value
--
-- KEY2 toggles step on/off
-- KEY3 TBD (fine-tune?)

--

-- TODO add top level options like direction, speed, internal/external clock, gate on, active steps etc.
-- see everything in the sequencer level block in the manual

local UI = require "ui"
local Sequencer = include("lib/sequencer")

local pages

local function step()
	seq1:step()
	seq1:autoscroll_page(pages)
	seq1:update_ui()
	redraw()
end

function init()
	pages = UI.Pages.new(1, 2)
	seq1 = Sequencer.new()
	seq1:build_params()

	crow.ii.pullup(true)
	-- crow input 1 is a clock requiring triggers
	crow.input[1].mode("change", 1, 0.1, "rising")
	crow.input[1].change = step

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

	seq1:build_params()
	params:default()
end

function enc(n, delta)
	local sequence = seq1:get_sequence(pages.index)
	if n == 1 then
		pages:set_index_delta(delta, false)
		seq1:update_ui()
	elseif n == 2 then
		sequence:select_step_by_delta(delta)
		seq1:update_ui()
	elseif n == 3 then
		sequence:set_selected_step_cv_by_delta(delta)
	end
	redraw()
end

function key(n, z)
	local sequence = seq1:get_sequence(pages.index)
	if n == 2 and z == 1 then
		sequence:toggle_selected_step()
	end
	redraw()
end

function redraw()
	screen.clear()
	pages:redraw()
	local sequence = seq1:get_sequence(pages.index)
	sequence:draw()
	screen.update()
end
