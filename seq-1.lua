-- seq-1
-- an SQ-1 for norns
--

local UI = require "ui"

local pages
local seqs = {}

local function build_dial_layout(x, y, xs, ys, size)
	local layout = {}
	layout.x_offset = x or 0
	layout.y_offset = y or 0
	layout.x_space = xs or 12
	layout.y_space = ys or 16
	layout.dial_size = 16 or size
	layout.button_width = layout.dial_size
	layout.button_height = layout.dial_size * 0.2
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
		seq.steps[i] = {
			cv = 0,
			gate_on = false,
			-- x, y, size, value, min_value, max_value, rounding
			dial = UI.Dial.new(seq.layout.dials[i].x, seq.layout.dials[i].y, seq.layout.dial_size, 0, 0, 1, 0.005)
		}
		seq.steps[i].dial.title = "cv " .. i
	end
	return seq
end

function init()
	crow.ii.pullup(true)
	pages = UI.Pages.new(1, 2)

	local dial_layout = build_dial_layout(0, 12, 10, 12, 14)
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
	screen.level(8)
	screen.move(0, 6)
	screen.text(seqs[pages.index].name)

	screen.update()
end
