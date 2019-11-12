local StepSeqUI = {}
StepSeqUI.__index = StepSeqUI

local UI = require "ui"

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

local function new_sequence_ui(seq_num, layout)
    local seq_ui = {}
    seq_ui.number = seq_num
    local letters = {"a", "b"}
    seq_ui.name = letters[seq_ui.number]
    seq_ui.steps = {}

    local tab_names = {}

    for i = 1, 8 do
        local slider_x = layout.sliders[i].x
        local slider_y = layout.sliders[i].y
        local slider_w = layout.slider_w
        local slider_h = layout.slider_h

        local btn_x = layout.buttons[i].x
        local btn_y = layout.buttons[i].y
        local btn_w = layout.button_w
        local btn_h = layout.button_h

        local hl_x = layout.highlights[i].x
        local hl_y = layout.highlights[i].y
        local hl_w = layout.highlight_width
        local hl_h = layout.highlight_height

        seq_ui.steps[i] = {
            slider = UI.Slider.new(slider_x, slider_y, slider_w, slider_h, 0, 0, 1),
            button = {x = btn_x, y = btn_y, w = btn_w, h = btn_h, active = false, gate_on = true},
            highlight = {x = hl_x, y = hl_y, w = hl_w, h = hl_h, active = false}
        }
        local step_name = "step " .. i
        table.insert(tab_names, step_name)
    end
    seq_ui.tabs = UI.Tabs.new(1, tab_names)

    return seq_ui
end

local function update_active_ui_elements(current_sequence_ui)
    local steps = current_sequence_ui.steps
    local active_step_num = current_sequence_ui.tabs.index

    for i, step in ipairs(steps) do
        if i == active_step_num then
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
        screen.level(12)
    else
        screen.level(6)
    end
    screen.rect(step.button.x, step.button.y, step.button.w, step.button.h)
    if step.button.gate_on then
        screen.fill()
    else
        screen.stroke()
    end
end

local function draw_highlight(step)
    if step.highlight.active == true then
        screen.level(12)
    else
        screen.level(6)
    end
    screen.rect(step.highlight.x, step.highlight.y, step.highlight.w, step.highlight.h)
    screen.fill()
end

local function draw_sequence_name(name)
    screen.level(10)
    screen.move(120, 8)
    screen.text(name)
end

function StepSeqUI.new(initial_seq_num)
    local step_seq_ui = {}
    step_seq_ui.layout = create_layout()
    step_seq_ui.sequence_uis = {}
    for i = 1, 2 do
        step_seq_ui.sequence_uis[i] = new_sequence_ui(i, step_seq_ui.layout)
    end
    step_seq_ui.current_sequence = initial_seq_num

    setmetatable(step_seq_ui, StepSeqUI)
    return step_seq_ui
end

function StepSeqUI:set_sequence(seq_num)
    self.current_sequence = seq_num

    local current = self.sequence_uis[self.current_sequence]
    update_active_ui_elements(current)
end

function StepSeqUI:active_step_num()
    local current = self.sequence_uis[self.current_sequence]
    local steps = current.steps
    local active_step_num = current.tabs.index

    return active_step_num
end

function StepSeqUI:active_step()
    local step_num = self:active_step_num()
    local current = self.sequence_uis[self.current_sequence]
    local active_step_num = current.tabs.index
    return current.steps[active_step_num]
end

function StepSeqUI:change_tabs(delta)
    local current = self.sequence_uis[self.current_sequence]
    current.tabs:set_index_delta(delta, false)

    update_active_ui_elements(current)
end

function StepSeqUI:draw()
    local current = self.sequence_uis[self.current_sequence]
    local steps = current.steps

    for num, step in ipairs(steps) do
        step.slider:redraw()
        draw_button(step)
        draw_highlight(step)
    end

    draw_sequence_name(current.name)
end

function StepSeqUI:update_active_step_slider(new_value)
    local step = self:active_step()
    step.slider:set_value(new_value)
end

function StepSeqUI:set_gate(new_gate)
    local step = self:active_step()
    step.button.gate_on = new_gate
end

return StepSeqUI
