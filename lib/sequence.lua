local Sequence = {}
Sequence.__index = Sequence

local UI = require "ui"
local SEQ_UI = include("lib/sequence_ui")
local SEQ_PARAMS = include("lib/sequence_params")
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
            slider = SEQ_UI.create_slider(i, layout),
            toggle = SEQ_UI.create_toggle(i, layout),
            highlight = SEQ_UI.create_highlight(i, layout)
        }
        table.insert(step_names, "step " .. i)
    end
    s.tabs = UI.Tabs.new(1, step_names)
    SEQ_UI.update_steps(s.steps, s.tabs.index)

    SEQ_PARAMS.create_sequence_params(s)
    SEQ_PARAMS.create_step_value_params(s)
    SEQ_PARAMS.create_step_active_params(s)

    setmetatable(s, Sequence)
    return s
end

function Sequence:get_value_for_step(step_num)
    local param_id = SEQ_PARAMS.param_id_for_step_value(self, step_num)
    return params:get(param_id)
end

function Sequence:get_active_for_step(step_num)
    local active_state = SEQ_PARAMS.param_id_for_step_active(self, step_num)
    -- 1 = OFF, 2 = ON
    if active_state == 1 then
        return false
    elseif active_state == 2 then
        return true
    end
end

function Sequence:get_active_for_step_as_param(step_num)
    local active_state = SEQ_PARAMS.param_id_for_step_active(self, step_num)
    return active_state
end

function Sequence:advance()
    local active_state = self:get_active_for_step(self.current_step)

    local value = nil
    if active_state then
        value = self:get_value_for_step(self.current_step)
    end

    self.current_step = self.current_step + 1
    if (self.current_step > self.length) then
        self.current_step = 1
    end

    return active_state, value
end

function Sequence:select_step_by_delta(delta)
    self.tabs:set_index_delta(delta, false)
end

function Sequence:set_step_value_by_delta(step_idx, delta)
    params:delta(SEQ_PARAMS.param_id_for_step_value(self, step_idx), delta)
end

function Sequence:set_selected_step_value_by_delta(delta)
    self:set_step_value_by_delta(self.tabs.index, delta)
end

function Sequence:toggle_step(step_idx)
    local state = params:string(SEQ_PARAMS.param_id_for_step_active(self, step_idx))
    local new_state
    if state == "OFF" then
        new_state = 2
    else
        new_state = 1
    end
    params:set(SEQ_PARAMS.param_id_for_step_active(self, step_idx), new_state)
end

function Sequence:toggle_selected_step()
    self:toggle_step(self.tabs.index)
end

function Sequence:update()
    SEQ_UI.update_steps(self.steps, self.tabs.index)
end

function Sequence:draw()
    for num, step in ipairs(self.steps) do
        step.slider:redraw()
        step.toggle:redraw()
        step.highlight:redraw()
    end

    SEQ_UI.draw_name(self.name, self.name_pos.x, self.name_pos.y)
end

function Sequence:set_cv_range(new_range)
    for _, step in ipairs(self.steps) do
        step.slider.max_value = new_range
    end
end

return Sequence
