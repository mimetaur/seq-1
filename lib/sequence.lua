local Sequence = {}
Sequence.__index = Sequence

local UI = require "ui"
local SEQ_UI = include("lib/sequence_ui")
local DEFAULT_LENGTH = 8

function Sequence.new(idx, length)
    local letters = {"A", "B"}
    local step_names = {}
    local layout = SEQ_UI.create_layout()

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
            slider = SEQ_UI.create_slider(i, layout),
            button = SEQ_UI.create_button(i, layout),
            highlight = SEQ_UI.create_highlight(i, layout)
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

function Sequence:select_step_by_delta(delta)
    self.tabs:set_index_delta(delta, false)
end

function Sequence:set_selected_step_value_by_delta(delta)
    local step = self.steps[self.tabs.index]
    local new_value = util.clamp(step.cv + (delta * 0.1), 0, 5)
    step.cv = new_value
    step.slider:set_value(new_value)
end

function Sequence:toggle_selected_step()
    local step = self.steps[self.tabs.index]
    step.active = not step.active
end

function Sequence:update()
    SEQ_UI.update_steps(self.steps, self.tabs.index)
end

function Sequence:draw()
    for num, step in ipairs(self.steps) do
        step.slider:redraw()
        SEQ_UI.draw_button(step)
        SEQ_UI.draw_highlight(step)
    end

    SEQ_UI.draw_name(self.name, self.name_pos.x, self.name_pos.y)
end

return Sequence
