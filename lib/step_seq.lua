local StepSeq = {}
StepSeq.__index = StepSeq

local UI = require "ui"
local StepSeqUI = include("lib/step_seq_ui")

local DEFAULT_NUM_STEPS = 8
local DEFAULT_NUM_SEQUENCES = 2
local DEFAULT_INITIAL_SEQUENCE = 1

local function create_sequence(seq_num, num_steps)
    local new_seq = {}
    new_seq.index = seq_num
    new_seq.current_step = 1
    new_seq.steps = {}
    new_seq.length = num_steps
    for i = 1, num_steps do
        new_seq.steps[i] = {
            sequence = new_seq,
            index = i,
            cv = 0,
            active = true
        }
    end

    return new_seq
end

function StepSeq.new(initial_seq_num, num_seqs)
    local num_sequences = num_seqs or DEFAULT_NUM_SEQUENCES

    local step_seq = {}
    step_seq.sequences = {}
    step_seq.current_sequence = initial_seq_num or DEFAULT_INITIAL_SEQUENCE
    step_seq.ui = StepSeqUI.new(step_seq)
    for i = 1, num_sequences do
        local new_sequence = create_sequence(i, DEFAULT_NUM_STEPS)
        step_seq.sequences[i] = step_seq.ui:create_sequence_ui(new_sequence)
    end
    step_seq.ui:initial_update(step_seq.sequences[step_seq.current_sequence])

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
        if (seq.current_step > seq.length) then
            seq.current_step = 1
        end
    end

    return output
end

function StepSeq:get_selected_sequence()
    return self.sequences[self.current_sequence]
end

function StepSeq:set_selected_sequence(seq_num)
    self.current_sequence = seq_num
    self.ui:update()
end

function StepSeq:select_step_by_delta(delta)
    self.ui:select_step_by_delta(delta)
    self.ui:update()
end

function StepSeq:set_selected_step_cv_by_delta(delta)
    local step = self:get_selected_step()
    local new_value = util.clamp(step.cv + (delta * 0.1), 0, 5)
    step.cv = new_value
    self.ui:update_slider(step, new_value)
end

function StepSeq:get_selected_step()
    return self:get_selected_sequence().steps[self.ui:get_selected_tab_index()]
end

function StepSeq:toggle_selected_step()
    local step = self:get_selected_step()
    step.active = not step.active
end

function StepSeq:draw()
    self.ui:draw()
end

return StepSeq
