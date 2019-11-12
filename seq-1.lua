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
			step.slider.active = true
			step.button.active = true
		else
			step.slider.active = false
			step.button.active = false
		end
	end
end

local function build_layout(x, y, sw, sh, xs, ys, bw, bh, hs)
	local layout = {}
	layout.x_offset = x or 6
	layout.y_offset = y or 8
	layout.slider_w = sw or 8
	layout.slider_h = sh or 32
	layout.x_space = xs or 6
	layout.y_space = ys or 8

	layout.button_w = bw or layout.slider_w
	layout.button_h = bh or math.floor(layout.slider_h * 0.25)

	layout.highlight_spacer = hs or 4

	layout.sliders = {}
	for i = 1, 8 do
		layout.sliders[i] = {}
		layout.sliders[i].x = layout.x_offset + ((i - 1) * (layout.slider_w + layout.x_space))
		layout.sliders[i].y = layout.y_offset
	end

	layout.highlights = {}
	for i = 1, 8 do
		layout.highlights[i] = {}
		layout.highlights[i].x = layout.sliders[i].x
		layout.highlights[i].y = layout.sliders[i].y - layout.highlight_spacer
		layout.highlights[i].w = layout.slider_w
		layout.highlights[i].h = 2
	end

	layout.buttons = {}
	for i = 1, 8 do
		layout.buttons[i] = {}
		layout.buttons[i].x = layout.x_offset + ((i - 1) * (layout.button_w + layout.x_space))
		layout.buttons[i].y = layout.y_offset + layout.slider_h + layout.y_space
	end
	return layout
end

local function build_sequence(seq_num, layout)
	local letters = {"a", "b"}
	local seq = {}
	seq.number = seq_num
	seq.name = letters[seq.number]
	seq.steps = {}
	seq.layout = layout
	local tab_names = {}

	for i = 1, 8 do
		local slider_x = seq.layout.sliders[i].x
		local slider_y = seq.layout.sliders[i].y
		local slider_w = seq.layout.slider_w
		local slider_h = seq.layout.slider_h
		seq.steps[i] = {
			sequence = seq,
			cv = 0,
			gate_on = true,
			slider = UI.Slider.new(slider_x, slider_y, slider_w, slider_h, 0, 0, 1),
			button = {
				x = seq.layout.buttons[i].x,
				y = seq.layout.buttons[i].y,
				w = seq.layout.button_w,
				h = seq.layout.button_h,
				active = false
			}
		}
		local step_name = "step " .. i
		table.insert(tab_names, step_name)
	end
	seq.tabs = UI.Tabs.new(1, tab_names)

	return seq
end

function init()
	crow.ii.pullup(true)
	pages = UI.Pages.new(1, 2)

	local layout = build_layout()
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
	elseif n == 3 then
		local step = get_active_step()
		step.cv = util.clamp(step.cv + (delta * 0.1), 0, 1)
		step.slider:set_value(step.cv)
	end
	redraw()
end

function key(n, z)
	if n == 2 and z == 1 then
		local step = get_active_step()
		step.gate_on = not step.gate_on
	end
	redraw()
end

function redraw()
	screen.clear()
	pages:redraw()

	local cur_seq = current_sequence()
	for num, step in ipairs(cur_seq.steps) do
		step.slider:redraw()

		if step.button.active == true then
			screen.level(12)
			screen.rect(
				cur_seq.layout.highlights[num].x,
				cur_seq.layout.highlights[num].y,
				cur_seq.layout.highlights[num].w,
				cur_seq.layout.highlights[num].h
			)
			screen.fill()
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
	screen.level(10)
	screen.move(120, 8)
	screen.text(cur_seq.name)

	screen.update()
end
