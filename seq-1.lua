-- seq-1
-- an SQ-1 for norns
--

local UI = require "ui"
local StepSeq = include("lib/step_seq")

local pages, step_seq, seq_ui

function init()
	crow.ii.pullup(true)
	pages = UI.Pages.new(1, 2)

	step_seq = StepSeq.new(pages.index)
end

function enc(n, delta)
	if n == 1 then
		pages:set_index_delta(delta, false)
		step_seq:set_sequence(pages.index)
	elseif n == 2 then
		step_seq:update_active_step(delta)
	elseif n == 3 then
		step_seq:update_step_cv(delta)
	end
	redraw()
end

function key(n, z)
	if n == 2 and z == 1 then
		step_seq:toggle_step_gate()
	end
	redraw()
end

function redraw()
	screen.clear()
	pages:redraw()
	step_seq:draw()
	screen.update()
end
