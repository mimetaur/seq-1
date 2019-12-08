-- seq-1
-- an SQ-1 for norns
--
-- ENC1 selects a sequence
-- ENC2 selects a step
-- ENC3 changes step value
--
-- KEY2 toggles step on/off
-- KEY3 + ENC2: fine tune
-- KEY3 + ENC3: rotate sequence

local UI = require "ui"
local Sequencer = include("lib/sequencer")
local g = grid.connect()
local a = arc.connect()

local pages

local function clear_grid()
	for y = 1, 8 do
		for x = 1, 16 do
			g:led(x, y, 0)
		end
	end
end

local function redraw_grid()
	clear_grid()
	local sequences = seq1:get_all_sequences()
	for i = 1, 2 do
		x_offset = 0
		if (i == 2) then
			x_offset = 8
		end

		-- draw gate row
		local gate_ons = sequences[i]:get_gate_on_indices()
		for _, index in ipairs(gate_ons) do
			g:led(x_offset + index, 8, 10)
		end

		for j = 1, 8 do
			local seq = sequences[i]
			local val = seq:cv_info_for_step_index(j)
			local min = seq.cv_min or 0
			local max = seq.cv_max or 5

			local bright = math.floor(util.linlin(min, max, 1, 15, val))
			g:led(x_offset + j, 7, bright)
		end
	end
	g:refresh()
end

local function redraw_arc()
	a:all(0)

	a:refresh()
end

a.delta = function(n, d)
	if (n == 1) then
	end

	seq1:update_ui()
	redraw_grid()
	redraw_arc()
	redraw()
end

g.key = function(x, y, z)
	print(x, y, z)

	if (z == 1) then
		if (y == 8) then
			-- gate row
			if (x < 9) then
				local seq = seq1:get_sequence(1)
				seq:toggle_step(x)
			else
				local seq = seq1:get_sequence(2)
				seq:toggle_step(x - 8)
			end
		end
	end

	if (seq1.autoscroll == true) then
		if (x < 9) then
			pages.index = 1
		else
			pages.index = 2
		end
	end

	seq1:update_ui()
	redraw_grid()
	redraw_arc()
	redraw()
end

local function step()
	seq1:step()
	seq1:autoscroll_page(pages)
	seq1:update_ui()
	redraw_arc()
	redraw_grid()
	redraw()
end

local function reset()
	print("resetting")
	seq1:reset()
	seq1:autoscroll_page(pages)
	seq1:update_ui()
	redraw_arc()
	redraw_grid()
	redraw()
end

function init()
	pages = UI.Pages.new(1, 2)
	seq1 = Sequencer.new()

	crow.ii.pullup(true)
	-- crow input 1 is a clock requiring triggers
	crow.input[1].mode("change", 1, 0.1, "rising")
	crow.input[1].change = step

	-- crow input 2 is a reset requiring a trigger
	crow.input[2].mode("change", 0.5, 0.1, "rising")
	crow.input[2].change = reset

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

	redraw_grid()
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
	redraw_grid()
	redraw_arc()
end

function key(n, z)
	local sequence = seq1:get_sequence(pages.index)
	if n == 2 and z == 1 then
		sequence:toggle_selected_step()
	end
	redraw()
	redraw_grid()
	redraw_arc()
end

function redraw()
	screen.clear()
	pages:redraw()
	local sequence = seq1:get_sequence(pages.index)
	sequence:draw()
	screen.update()
end
