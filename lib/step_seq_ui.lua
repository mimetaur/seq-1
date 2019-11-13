local StepSeqUI = {}
StepSeqUI.__index = StepSeqUI

local UI = require "ui"

local LEVEL_HI = 12
local LEVEL_MED = 8
local LEVEL_LO = 6

local function update_tabs(steps, selected_idx)
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

local function draw_name(self)
    screen.level(LEVEL_MED)
    screen.move(self.layout.name_x, self.layout.name_y)
    screen.text(self:get_name())
end

function StepSeqUI.new(parent_seq)
    local seq_ui = {}
    seq_ui.step_seq = parent_seq
    seq_ui.layout = create_layout()

    setmetatable(seq_ui, StepSeqUI)
    return seq_ui
end

function StepSeqUI:create_sequence_ui(new_sequence)
    local letters = {"A", "B"}
    local step_names = {}
    for i, step in ipairs(new_sequence.steps) do
        step.slider = self:create_slider(i)
        step.button = self:create_button(i)
        step.highlight = self:create_highlight(i)
        table.insert(step_names, "step " .. i)
    end

    new_sequence.name = letters[new_sequence.index]
    new_sequence.tabs = UI.Tabs.new(1, step_names)

    return new_sequence
end

function StepSeqUI:select_step_by_delta(delta)
    local tabs = self.step_seq:get_selected_sequence().tabs
    tabs:set_index_delta(delta, false)
end

function StepSeqUI:update_slider(step, new_value)
    step.slider:set_value(new_value)
end

function StepSeqUI:get_selected_tab_index()
    return self.step_seq:get_selected_sequence().tabs.index
end

function StepSeqUI:get_steps()
    return self.step_seq:get_selected_sequence().steps
end

function StepSeqUI:get_name()
    return self.step_seq:get_selected_sequence().name
end

function StepSeqUI:draw(steps, name)
    local steps = self:get_steps()
    local name = self:get_name()

    for num, step in ipairs(steps) do
        step.slider:redraw()
        draw_button(step)
        draw_highlight(step)
    end

    draw_name(self)
end

function StepSeqUI:create_slider(step_num)
    local slider_x = self.layout.sliders[step_num].x
    local slider_y = self.layout.sliders[step_num].y
    local slider_w = self.layout.slider_w
    local slider_h = self.layout.slider_h

    return UI.Slider.new(slider_x, slider_y, slider_w, slider_h, 0, 0, 5)
end

function StepSeqUI:create_button(step_num)
    local btn_x = self.layout.buttons[step_num].x
    local btn_y = self.layout.buttons[step_num].y
    local btn_w = self.layout.button_w
    local btn_h = self.layout.button_h
    local btn = {x = btn_x, y = btn_y, w = btn_w, h = btn_h, active = false, gate_on = true}
    return btn
end

function StepSeqUI:create_highlight(step_num)
    local hl_x = self.layout.highlights[step_num].x
    local hl_y = self.layout.highlights[step_num].y
    local hl_w = self.layout.highlight_width
    local hl_h = self.layout.highlight_height
    local highlight = {x = hl_x, y = hl_y, w = hl_w, h = hl_h, active = false}
    return highlight
end

function StepSeqUI:update(sequence)
    update_tabs(self:get_steps(), self:get_selected_tab_index())
end

function StepSeqUI:initial_update(sequence)
    update_tabs(sequence.steps, sequence.tabs.index)
end

return StepSeqUI
