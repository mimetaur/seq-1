local Sequence = {}
Sequence.__index = Sequence

local UI = require "ui"
local SEQ_UI = include("lib/sequence_ui")
local SEQ_PARAMS = include("lib/sequence_params")
local CV_UTILS = include("lib/cv_utils")
local DEFAULT_LENGTH = 8

local function get_value_for_step(step)
    return params:get(step.params.value)
end

local function get_active_for_step(step)
    local active_state = params:get(step.params.active)
    -- 1 = OFF, 2 = ON
    if active_state == 1 then
        return false
    elseif active_state == 2 then
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
    SEQ_PARAMS.build_step_value_params(self)
    SEQ_PARAMS.build_step_active_params(self)
end

function Sequence:play_current_step()
    local current_step = self.steps[self.current_step]

    local is_active = get_active_for_step(current_step)
    local cv = nil
    if is_active then
        cv = get_value_for_step(current_step) + self.octave
        if self.scale then
            local note = CV_UTILS.quantize(cv, self.scale)
            cv = CV_UTILS.n2v(note)
        end
    end
    return is_active, cv
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

function Sequence:select_step_by_delta(delta)
    self.tabs:set_index_delta(delta, false)
end

function Sequence:set_step_value_by_delta(step_idx, delta)
    local step = self.steps[step_idx]
    params:delta(step.params.value, delta)
end

function Sequence:set_selected_step_value_by_delta(delta)
    self:set_step_value_by_delta(self.tabs.index, delta)
end

function Sequence:toggle_step(step_idx)
    local step = self.steps[step_idx]
    -- TODO something seems overcomplicated in my toggles
    local state = params:string(step.params.active)
    local new_state
    if state == "OFF" then
        new_state = 2
    else
        new_state = 1
    end
    params:set(step.params.active, new_state)
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
        local step_value_param = params:lookup_param(step.params.value)
        step_value_param.controlspec.maxval = new_range

        -- update slider UI with a new max
        step.slider.max_value = new_range
        local slider_val = params:get(step.params.value)
        step.slider:set_value(slider_val)
    end
end

function Sequence:reset()
    self.current_step = 1
end

return Sequence
