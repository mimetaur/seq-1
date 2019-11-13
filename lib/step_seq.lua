local StepSeq = {}
StepSeq.__index = StepSeq

local UI = require "ui"
local step_seq_ui = include("lib/step_seq_ui")
local MAX_STEPS = 8

local function get_selected_sequence(self)
    return self.sequences[self.current_sequence]
end

local function get_selected_step(self)
    local sequence = get_selected_sequence(self)
    return sequence.steps[sequence.tabs.index]
end

local function create_sequence(seq_num)
    local new_seq = {}

    local letters = {"A", "B"}
    local step_names = {}

    new_seq.index = seq_num
    new_seq.name = letters[seq_num]
    new_seq.layout = step_seq_ui.create_layout()
    new_seq.current_step = 1
    new_seq.steps = {}
    for i = 1, MAX_STEPS do
        new_seq.steps[i] = {
            sequence = new_seq,
            index = i,
            cv = 0,
            active = true,
            slider = step_seq_ui.create_slider(i, new_seq.layout),
            button = step_seq_ui.create_button(i, new_seq.layout),
            highlight = step_seq_ui.create_highlight(i, new_seq.layout)
        }
        table.insert(step_names, "step " .. i)
    end
    new_seq.tabs = UI.Tabs.new(1, step_names)

    return new_seq
end

function StepSeq.new(initial_seq_num)
    local step_seq = {}
    step_seq.sequences = {}
    for i = 1, 2 do
        step_seq.sequences[i] = create_sequence(i)
    end
    step_seq.current_sequence = initial_seq_num or 1
    step_seq.current_step = 1

    local seq = step_seq.sequences[step_seq.current_sequence]
    step_seq_ui.update_active_ui_elements(seq.steps, seq.tabs.index)

    setmetatable(step_seq, StepSeq)
    return step_seq
end

function StepSeq:advance()
    local output = {}
    for i = 1, 2 do
        local seq = self.sequences[i]
        local step = seq.steps[seq.current_step]
        output[i] = {}
        output[i].gate = step.active
        if step.active then
            output[i].cv = step.cv
        else
            output[i].cv = nil
        end

        seq.current_step = seq.current_step + 1
        if (seq.current_step > MAX_STEPS) then
            seq.current_step = 1
        end
    end

    return output
end

function StepSeq:set_selected_sequence(seq_num)
    self.current_sequence = seq_num
    local sequence = get_selected_sequence(self)
    step_seq_ui.update_active_ui_elements(sequence.steps, sequence.tabs.index)
end

function StepSeq:select_step_by_delta(delta)
    local sequence = get_selected_sequence(self)
    sequence.tabs:set_index_delta(delta, false)
    step_seq_ui.update_active_ui_elements(sequence.steps, sequence.tabs.index)
end

function StepSeq:set_selected_step_cv_by_delta(delta)
    local step = get_selected_step(self)
    local new_value = util.clamp(step.cv + (delta * 0.1), 0, 5)
    step.cv = new_value
    step_seq_ui.update_slider(step, new_value)
end

function StepSeq:toggle_selected_step()
    local step = get_selected_step(self)
    step.gate_on = not step.gate_on
end

function StepSeq:draw()
    local sequence = get_selected_sequence(self)
    step_seq_ui.draw_ui(sequence.steps, sequence.name)
end

return StepSeq
