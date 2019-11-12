local StepSeq = {}
StepSeq.__index = StepSeq

local UI = require "ui"
local step_seq_ui = include("lib/step_seq_ui")

local function new_sequence(seq_num)
    local new_seq = {}

    local letters = {"A", "B"}
    local step_names = {}

    new_seq.number = seq_num
    new_seq.name = letters[seq_num]
    new_seq.layout = step_seq_ui.create_layout()
    new_seq.steps = {}
    for i = 1, 8 do
        new_seq.steps[i] = {
            sequence = new_seq,
            index = i,
            cv = 0,
            gate_on = true,
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
        step_seq.sequences[i] = new_sequence(i)
    end
    step_seq.current_sequence = initial_seq_num or 1

    local seq = step_seq.sequences[step_seq.current_sequence]
    step_seq_ui.update_active_ui_elements(seq.steps, seq.tabs.index)

    setmetatable(step_seq, StepSeq)
    return step_seq
end

function StepSeq:get_sequence()
    return self.sequences[self.current_sequence]
end

function StepSeq:set_sequence(seq_num)
    self.current_sequence = seq_num
    local sequence = self:get_sequence()
    step_seq_ui.update_active_ui_elements(sequence.steps, sequence.tabs.index)
end

function StepSeq:get_active_step()
    local sequence = self:get_sequence()
    return sequence.steps[sequence.tabs.index]
end

function StepSeq:update_active_step(delta)
    local sequence = self:get_sequence()
    sequence.tabs:set_index_delta(delta, false)
    step_seq_ui.update_active_ui_elements(sequence.steps, sequence.tabs.index)
end

function StepSeq:update_step_cv(delta)
    local step = self:get_active_step()
    local new_value = util.clamp(step.cv + (delta * 0.1), 0, 1)
    step.cv = new_value
    step_seq_ui.update_slider(step, new_value)
end

function StepSeq:toggle_step_gate()
    local step = self:get_active_step()
    step.gate_on = not step.gate_on
end

function StepSeq:draw()
    local sequence = self:get_sequence()
    step_seq_ui.draw_ui(sequence.steps, sequence.name)
end

return StepSeq
