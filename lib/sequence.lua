local Sequence = {}
Sequence.__index = Sequence

local UI = require "ui"

local DEFAULT_LENGTH = 8
local LEVEL_HI = 12
local LEVEL_MED = 8
local LEVEL_LO = 6

local function create_layout(x, y, sw, sh, xs, ys, bw, bh, hs, hw, hh)
    local layout = {}
    layout.x_offset = x or 6
    layout.y_offset = y or 10
    layout.slider_w = sw or 8
    layout.slider_h = sh or 36
    layout.x_space = xs or 6
    layout.y_space = ys or 4

    layout.button_w = bw or layout.slider_w
    layout.button_h = bh or math.floor(layout.slider_h * 0.2)

    layout.highlight_spacer = hs or 6
    layout.highlight_width = hw or layout.slider_w
    layout.highlight_height = hh or 2

    layout.name_x = 120
    layout.name_y = 8

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
    end

    layout.buttons = {}
    for i = 1, 8 do
        layout.buttons[i] = {}
        layout.buttons[i].x = layout.x_offset + ((i - 1) * (layout.button_w + layout.x_space))
        layout.buttons[i].y = layout.y_offset + layout.slider_h + layout.y_space
    end
    return layout
end

local function create_slider(step_num, layout)
    local slider_x = layout.sliders[step_num].x
    local slider_y = layout.sliders[step_num].y
    local slider_w = layout.slider_w
    local slider_h = layout.slider_h

    return UI.Slider.new(slider_x, slider_y, slider_w, slider_h, 0, 0, 5)
end

local function create_button(step_num, layout)
    local btn_x = layout.buttons[step_num].x
    local btn_y = layout.buttons[step_num].y
    local btn_w = layout.button_w
    local btn_h = layout.button_h
    local btn = {x = btn_x, y = btn_y, w = btn_w, h = btn_h, active = false, gate_on = true}
    return btn
end

local function create_highlight(step_num, layout)
    local hl_x = layout.highlights[step_num].x
    local hl_y = layout.highlights[step_num].y
    local hl_w = layout.highlight_width
    local hl_h = layout.highlight_height
    local highlight = {x = hl_x, y = hl_y, w = hl_w, h = hl_h, active = false}
    return highlight
end

local function update_steps(steps, selected_idx)
    for i, step in ipairs(steps) do
        if i == selected_idx then
            step.slider.active = true
            step.button.active = true
            step.highlight.active = true
        else
            step.slider.active = false
            step.button.active = false
            step.highlight.active = false
        end
    end
end

local function draw_button(step)
    if step.button.active == true then
        screen.level(LEVEL_HI)
    else
        screen.level(LEVEL_LO)
    end
    screen.rect(step.button.x, step.button.y, step.button.w, step.button.h)
    if step.active then
        screen.fill()
    else
        screen.stroke()
    end
end

local function draw_highlight(step)
    if step.highlight.active == true then
        screen.level(LEVEL_HI)
    else
        screen.level(LEVEL_LO)
    end
    screen.rect(step.highlight.x, step.highlight.y, step.highlight.w, step.highlight.h)
    screen.fill()
end

local function draw_name(name, x, y)
    screen.level(LEVEL_MED)
    screen.move(x, y)
    screen.text(name)
end

function Sequence.new(idx, length)
    local letters = {"A", "B"}
    local step_names = {}
    local layout = create_layout()

    local s = {}
    s.index = idx or 1
    s.name = letters[s.index]
    s.name_pos = {x = layout.name_x, y = layout.name_y}
    s.current_step = 1
    s.steps = {}
    s.length = length or DEFAULT_LENGTH
    for i = 1, s.length do
        s.steps[i] = {
            index = i,
            cv = 0,
            active = true,
            slider = create_slider(i, layout),
            button = create_button(i, layout),
            highlight = create_highlight(i, layout)
        }
        table.insert(step_names, "step " .. i)
    end
    s.tabs = UI.Tabs.new(1, step_names)

    setmetatable(s, Sequence)
    return s
end

function Sequence:advance()
    local output = {}
    local step = self.steps[self.current_step]
    output.gate = step.active
    if step.active then
        output.cv = step.cv
    else
        output.cv = nil
    end

    self.current_step = self.current_step + 1
    if (self.current_step > self.length) then
        self.current_step = 1
    end

    return output
end

function Sequence:toggle_selected_step()
    local step = self.steps[self.tabs.index]
    step.active = not step.active
end

function Sequence:update()
    update_steps(self.steps, self.tabs.index)
end

function Sequence:select_step_by_delta(delta)
    self.tabs:set_index_delta(delta, false)
end

function Sequence:set_selected_step_value_by_delta(delta)
    local step = self.steps[self.tabs.index]
    local new_value = util.clamp(step.cv + (delta * 0.1), 0, 5)
    step.cv = new_value
    step.slider:set_value(new_value)
end

function Sequence:draw()
    for num, step in ipairs(self.steps) do
        step.slider:redraw()
        draw_button(step)
        draw_highlight(step)
    end

    draw_name(self.name, self.name_pos.x, self.name_pos.y)
end

return Sequence
