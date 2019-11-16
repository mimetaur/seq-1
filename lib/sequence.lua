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
                step.cv = value
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
                if value == 1 then
                    step.active = false
                else
                    step.active = true
                end
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
    local param_id = self.index .. "_" .. "step_" .. self.tabs.index .. "_value"
    params:delta(create_param_id_for_value(self.index, self.tabs.index), delta)
end

function Sequence:toggle_selected_step()
    local step = self.steps[self.tabs.index]
    local new_active = not step.active
    local output = 1
    if new_active == true then
        output = 2
    end
    params:set(create_param_id_for_toggle(self.index, self.tabs.index), output)
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
