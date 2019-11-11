-- seq-1
-- an SQ-1 for norns
--

local UI = require "ui"

local pages
local seqs = {}

local function current_sequence()
	return seqs[pages.index]
end

local function get_active_step()
	local current_seq = current_sequence()
	local steps = current_seq.steps
	local active_step_num = current_seq.tabs.index

	return steps[active_step_num]
end

local function set_active_step()
	local current_seq = current_sequence()
	local steps = current_seq.steps
	local active_step_num = current_seq.tabs.index

	for i, step in ipairs(steps) do
		if i == active_step_num then
			step.dial.active = true
			step.button.active = true
		else
			step.dial.active = false
			step.button.active = false
		end
	end
end

local function build_layout(x, y, xs, ys, size)
	local layout = {}
	layout.x_offset = x or 4
	layout.y_offset = y or 0
	layout.x_space = xs or 12
	layout.y_space = ys or 16
	layout.dial_size = size or 16
	layout.button_width = layout.dial_size
	layout.button_height = math.floor(layout.y_space * 0.3)
	layout.button_y_offset = math.floor(layout.y_space * 0.6)

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

	layout.buttons = {}
	for i = 1, 4 do
		layout.buttons[i] = {}
		layout.buttons[i].x = layout.x_offset + ((i - 1) * (layout.button_width + layout.x_space))
		layout.buttons[i].y = layout.y_offset + layout.dial_size + layout.button_y_offset
	end
	for i = 5, 8 do
		layout.buttons[i] = {}
		layout.buttons[i].x = layout.x_offset + ((i - 5) * (layout.button_width + layout.x_space))
		layout.buttons[i].y = layout.y_offset + (layout.dial_size * 2) + layout.y_space + layout.button_y_offset
	end
	return layout
end

local function build_sequence(seq_num, layout)
	local seq = {}
	seq.number = seq_num
	seq.name = "seq #" .. seq_num
	seq.steps = {}
	seq.layout = layout
	local tab_names = {}

	for i = 1, 8 do
		local dial_x = seq.layout.dials[i].x
		local dial_y = seq.layout.dials[i].y
		local dial_size = seq.layout.dial_size
		seq.steps[i] = {
			sequence = seq,
			cv = 0,
			gate_on = false,
			dial = UI.Dial.new(dial_x, dial_y, dial_size, 0, 0, 1, 0.005),
			button = {
				x = seq.layout.buttons[i].x,
				y = seq.layout.buttons[i].y,
				w = seq.layout.button_width,
				h = seq.layout.button_height,
				active = false
			}
		}
		local title = "cv " .. i
		seq.steps[i].dial.title = title
		local step_name = "step " .. i
		table.insert(tab_names, step_name)
	end
	seq.tabs = UI.Tabs.new(1, tab_names)

	return seq
end

function init()
	crow.ii.pullup(true)
	pages = UI.Pages.new(1, 2)

	local layout = build_layout(4, 0, 12, 18, 14)
	for i = 1, 2 do
		seqs[i] = build_sequence(i, layout)
	end
	set_active_step()
end

function enc(n, delta)
	if n == 1 then
		pages:set_index_delta(delta, false)
		set_active_step()
	elseif n == 2 then
		local cur_seq = current_sequence()
		cur_seq.tabs:set_index_delta(delta, false)
		set_active_step()
	end
	redraw()
end

function key(n, z)
	print(n .. "," .. z)

	if n == 3 and z == 1 then
		local step = get_active_step()
		step.gate_on = not step.gate_on
	end
	redraw()
end

function redraw()
	screen.clear()
	pages:redraw()

	local cur_seq = current_sequence()
	for _, step in ipairs(cur_seq.steps) do
		step.dial:redraw()

		if step.button.active == true then
			screen.level(14)
		else
			screen.level(6)
		end
		screen.rect(step.button.x, step.button.y, step.button.w, step.button.h)
		if step.gate_on then
			screen.fill()
		else
			screen.stroke()
		end
	end
	screen.update()
end
