-- seq-1
-- an SQ-1 for norns
--

local UI = require "ui"

local pages
local seqs = {}

local function build_dial_layout(x, y, xs, ys, size)
	local layout = {}
	layout.x_offset = x or 4
	layout.y_offset = y or 0
	layout.x_space = xs or 12
	layout.y_space = ys or 16
	layout.dial_size = size or 16

	layout.dials = {}
	for i = 1, 4 do
		layout.dials[i] = {}
		layout.dials[i].x = layout.x_offset + ((i - 1) * (layout.dial_size + layout.x_space))
		layout.dials[i].y = layout.y_offset
	end
	for i = 5, 8 do
		layout.dials[i] = {}
		layout.dials[i].x = layout.x_offset + ((i - 5) * (layout.dial_size + layout.x_space))
		layout.dials[i].y = layout.y_offset + ((layout.dial_size) + layout.y_space)
	end
	return layout
end

local function build_sequence(seq_num, layout)
	local seq = {}
	seq.number = seq_num
	seq.name = "seq #" .. seq_num
	seq.steps = {}
	seq.layout = layout

	for i = 1, 8 do
		local x = seq.layout.dials[i].x
		local y = seq.layout.dials[i].y
		local size = seq.layout.dial_size
		seq.steps[i] = {
			cv = 0,
			gate_on = false,
			dial = UI.Dial.new(x, y, size, 0, 0, 1, 0.005)
		}
		seq.steps[i].dial.title = "cv " .. i
	end
	return seq
end

function init()
	crow.ii.pullup(true)
	pages = UI.Pages.new(1, 2)

	local dial_layout = build_dial_layout(4, 2, 13, 17, 14)
	for i = 1, 2 do
		seqs[i] = build_sequence(i, dial_layout)
	end
end

function enc(n, delta)
	pages:set_index_delta(delta, false)

	redraw()
end

function key(n, z)
	print(n .. "," .. z)
	redraw()
end

function redraw()
	screen.clear()
	pages:redraw()

	for _, step in ipairs(seqs[pages.index].steps) do
		step.dial:redraw()
	end
	screen.update()
end
