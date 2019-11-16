local Sequence = {}
Sequence.__index = Sequence

local UI = require "ui"
local SEQ_UI = include("lib/sequence_ui")
local DEFAULT_LENGTH = 8

local function create_value_params(self)
    params:add_separator()
    local linear_volts_cs = controlspec.new(0, 5, "lin", 0, 0, "volts")
    for _, step in ipairs(self.steps) do
        params:add {
            type = "control",
            id = self.index .. "_" .. "step_" .. step.index .. "_value",
            name = "seq " .. self.name .. ": " .. "step " .. step.index .. " value",
            controlspec = linear_volts_cs,
            action = function(value)
                step.slider:set_value(value)
            end
        }
    end
end

local function create_active_params(self)
    params:add_separator()
    for _, step in ipairs(self.steps) do
        params:add {
            type = "option",
            id = self.index .. "_" .. "step_" .. step.index .. "_active",
            name = "seq " .. self.name .. ": " .. "step " .. step.index .. " active",
            options = {"OFF", "ON"},
            default = 2,
            action = function(value)
                step.toggle:toggle()
            end
        }
    end
end

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

    create_value_params(s)
    create_active_params(s)

    setmetatable(s, Sequence)
    return s
end

function Sequence:param_id_for_step_value(step_num)
    return self.index .. "_" .. "step_" .. step_num .. "_value"
end

function Sequence:param_id_for_step_active(step_num)
    return self.index .. "_" .. "step_" .. step_num .. "_active"
end

function Sequence:get_value_for_step(step_num)
    local param_id = self:param_id_for_step_value(step_num)
    return params:get(param_id)
end

function Sequence:get_active_for_step(step_num)
    local active_state = self:param_id_for_step_active(step_num)
    -- 1 = OFF, 2 = ON
    if active_state == 1 then
        return false
    elseif active_state == 2 then
        return true
    end
end

function Sequence:advance()
    local active_state = self:get_active_for_step(self.current_step)

    local value = nil
    if toggle_state then
        value = self:get_value_for_step(self.current_step)
    end

    self.current_step = self.current_step + 1
    if (self.current_step > self.length) then
        self.current_step = 1
    end

    return toggle_state, value
end

function Sequence:select_step_by_delta(delta)
    self.tabs:set_index_delta(delta, false)
end

function Sequence:set_step_value_by_delta(step_idx, delta)
    params:delta(self:param_id_for_step_value(step_idx), delta)
end

function Sequence:set_selected_step_value_by_delta(delta)
    self:set_step_value_by_delta(self.tabs.index, delta)
end

function Sequence:toggle_step(step_idx)
    local active_state = params:get(self:param_id_for_step_active(step_idx))
    local new_active_state
    if active_state == 1 then
        new_active_state = 2
    else
        new_active_state = 1
    end
    params:set(self:param_id_for_step_active(step_idx), new_active_state)
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

return Sequence
