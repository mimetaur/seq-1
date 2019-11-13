-- seq-1
-- an SQ-1 for norns
--

local UI = require "ui"
local StepSeq = include("lib/step_seq")

local pages, step_seq

local function on_input_one_change()
	local step = step_seq:advance()
	if step[1].cv then
		crow.output[1].volts = step[1].cv
		print("advancing " .. step[1].cv)
	end
	if step[1].gate then
		crow.output[2].execute()
	end
end

function init()
	pages = UI.Pages.new(1, 2)
	step_seq = StepSeq.new(pages.index)

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
		step_seq:set_selected_sequence(pages.index)
	elseif n == 2 then
		step_seq:select_step_by_delta(delta)
	elseif n == 3 then
		step_seq:set_selected_step_cv_by_delta(delta)
	end
	redraw()
end

function key(n, z)
	if n == 2 and z == 1 then
		step_seq:toggle_selected_step()
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
	step_seq:draw()
	screen.update()
end
