local Sequence = {}
Sequence.__index = Sequence

local UI = require "ui"
local SEQ_UI = include("lib/sequence_ui")
local DEFAULT_LENGTH = 8

local function add_value_params(self)
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

    params:add_separator()
end

local function add_toggle_params(self)
    for _, step in ipairs(self.steps) do
        params:add {
            type = "option",
            id = self.index .. "_" .. "step_" .. step.index .. "_toggle",
            name = "seq " .. self.name .. ": " .. "step " .. step.index .. " toggle",
            options = {"OFF", "ON"},
            default = 2,
            action = function(value)
                step.toggle:toggle()
            end
        }
    end
    params:add_separator()
end

local function create_param_id_for_value(sequence_num, step_num)
    return sequence_num .. "_" .. "step_" .. step_num .. "_value"
end

local function create_param_id_for_toggle(sequence_num, step_num)
    return sequence_num .. "_" .. "step_" .. step_num .. "_toggle"
end

local function get_value_for_step(sequence_num, step_num)
    return params:get(create_param_id_for_value(sequence_num, step_num))
end

local function get_toggle_for_step(sequence_num, step_num)
    local toggle = params:get(create_param_id_for_toggle(sequence_num, step_num))
    -- 1 = OFF, 2 = ON
    if toggle == 1 then
        return false
    else
        return true
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

    add_value_params(s)
    add_toggle_params(s)

    setmetatable(s, Sequence)
    return s
end

function Sequence:advance()
    local toggle = get_toggle_for_step(self.index, self.current_step.index)

    local value = nil
    if toggle then
        value = get_value_for_step(self.index, self.current_step.index)
    end

    self.current_step = self.current_step + 1
    if (self.current_step > self.length) then
        self.current_step = 1
    end

    return toggle, value
end

function Sequence:select_step_by_delta(delta)
    self.tabs:set_index_delta(delta, false)
end

function Sequence:set_selected_step_value_by_delta(delta)
    params:delta(create_param_id_for_value(self.index, self.tabs.index), delta)
end

function Sequence:toggle_selected_step()
    local toggle_bool = get_toggle_for_step(self.index, self.tabs.index)
    -- 1 = OFF, 2 = ON
    local toggle_num = 2
    if toggle_bool == true then
        toggle_num = 1
    end
    params:set(create_param_id_for_toggle(self.index, self.tabs.index), toggle_num)
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
