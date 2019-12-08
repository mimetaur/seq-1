local Sequence = {}
Sequence.__index = Sequence

local UI = require "ui"
local SEQ_UI = include("lib/sequence_ui")
local SEQ_PARAMS = include("lib/sequence_params")
local CV_UTILS = include("lib/cv_utils")
local DEFAULT_LENGTH = 8

local function gate_as_boolean(gate_number)
    local result = {}
    result[1] = false
    result[2] = true

    return result[gate_number]
end

local function gate_as_number(gate_boolean)
    local result = {}
    result[false] = 1
    result[true] = 2

    return result[gate_boolean]
end

local function get_cv_for_step(step)
    return params:get(step.params.cv)
end

local function get_gate_for_step(step)
    local gate = params:get(step.params.gate)
    return gate_as_boolean(gate)
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
            params = {},
            slider = SEQ_UI.create_slider(i, layout),
            toggle = SEQ_UI.create_toggle(i, layout),
            highlight = SEQ_UI.create_highlight(i, layout)
        }
        table.insert(step_names, "step " .. i)
    end
    s.tabs = UI.Tabs.new(1, step_names)
    s.scale = nil
    s.octave = 0
    s.speed = 1
    s.params = {}
    SEQ_UI.update_steps(s.steps, s.tabs.index, s.current_step)

    setmetatable(s, Sequence)
    return s
end

function Sequence:build_params()
    SEQ_PARAMS.build_sequence_params(self)
    SEQ_PARAMS.build_step_cv_params(self)
    SEQ_PARAMS.build_step_gate_params(self)
end

function Sequence:play_current_step()
    local current_step = self.steps[self.current_step]

    local gate = get_gate_for_step(current_step)
    local cv = get_cv_for_step(current_step) + self.octave
    if self.scale then
        local note = CV_UTILS.quantize(cv, self.scale)
        cv = CV_UTILS.n2v(note)
    end
    return gate, cv
end

function Sequence:advance(mode)
    status = nil
    if mode == "PARALLEL" or mode == "ALTERNATING" then
        self.speed = 1
        self.current_step = self.current_step + self.speed
        if (self.current_step > self.length) then
            self:reset()
        end
    elseif mode == "PARALLEL_REVERSING" then
        if self.current_step == self.length then
            self.speed = -1
        elseif self.current_step == 1 then
            self.speed = 1
        end
        self.current_step = self.current_step + self.speed
    elseif mode == "SUCCESSIVE" then
        self.speed = 1
        if self.current_step == self.length then
            status = true
            self:reset()
        else
            self.current_step = self.current_step + self.speed
            status = false
        end
    end
    return status
end

function Sequence:select_step(step_index)
    self.tabs:set_index(step_index, false)
end

function Sequence:select_step_by_delta(delta)
    self.tabs:set_index_delta(delta, false)
end

function Sequence:set_step_cv_by_delta(step_idx, delta)
    local step = self.steps[step_idx]
    params:delta(step.params.cv, delta)
end

function Sequence:set_selected_step_cv_by_delta(delta)
    self:set_step_cv_by_delta(self.tabs.index, delta)
end

function Sequence:toggle_step(step_idx)
    local step = self.steps[step_idx]
    local toggled_gate = not get_gate_for_step(step)

    params:set(step.params.gate, gate_as_number(toggled_gate))
end

function Sequence:toggle_selected_step()
    self:toggle_step(self.tabs.index)
end

function Sequence:update_ui()
    SEQ_UI.update_steps(self.steps, self.tabs.index, self.current_step)
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
        -- update param with a new max
        -- not sure about editing this at runtime
        -- but it is working fine
        local step_cv_param = params:lookup_param(step.params.cv)
        step_cv_param.controlspec.maxval = new_range

        self.cv_max = step_cv_param.controlspec.maxval
        self.cv_min = step_cv_param.controlspec.minval

        -- update slider UI with a new max
        step.slider.max_value = new_range
        local slider_val = params:get(step.params.cv)
        step.slider:set_value(slider_val)
    end
end

function Sequence:reset()
    self.current_step = 1
end

function Sequence:get_selected_step_index()
    return self.tabs.index
end

function Sequence:get_gate_on_indices()
    local gate_indices = {}
    for _, step in ipairs(self.steps) do
        if (get_gate_for_step(step) == true) then
            table.insert(gate_indices, step.index)
        end
    end
    return gate_indices
end

function Sequence:cv_info_for_step_index(idx)
    local step = self.steps[idx]
    return get_cv_for_step(step)
end

return Sequence
