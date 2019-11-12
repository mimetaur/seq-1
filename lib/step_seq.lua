local StepSeq = {}
StepSeq.__index = StepSeq

local StepSeqUI = include("lib/step_seq_ui")

local function new_sequence(seq_num)
    local new_sequence = {}
    new_sequence.number = seq_num

    new_sequence.steps = {}
    for i = 1, 8 do
        new_sequence.steps[i] = {
            sequence = new_sequence,
            cv = 0,
            gate_on = true
        }
    end
    return new_sequence
end

function StepSeq.new(initial_seq_num)
    local step_seq = {}
    step_seq.sequences = {}
    for i = 1, 2 do
        step_seq.sequences[i] = new_sequence(i)
    end
    step_seq.current_sequence = initial_seq_num

    step_seq.seq_ui = StepSeqUI.new(initial_seq_num)
    step_seq.seq_ui:set_sequence(initial_seq_num)

    setmetatable(step_seq, StepSeq)
    return step_seq
end

function StepSeq:set_sequence(seq_num)
    self.current_sequence = seq_num
    self.seq_ui:set_sequence(seq_num)
end

function StepSeq:change_active_step(delta)
    self.seq_ui:change_tabs(delta)
end

function StepSeq:active_step_num()
    return self.seq_ui:active_step_num()
end

function StepSeq:active_step()
    local step_num = self:active_step_num()
    return self.sequences[self.current_sequence].steps[step_num]
end

function StepSeq:update_step_value(delta)
    local step = self:active_step()
    local new_value = util.clamp(step.cv + (delta * 0.1), 0, 1)
    step.cv = new_value
    self.seq_ui:update_active_step_slider(new_value)
end

function StepSeq:toggle_step()
    local step = self:active_step()
    step.gate_on = not step.gate_on
    self.seq_ui:set_gate(step.gate_on)
end

function StepSeq:draw()
    self.seq_ui:draw()
end

return StepSeq
