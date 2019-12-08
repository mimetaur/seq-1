local Sequencer = {}
Sequencer.__index = Sequencer

local Sequence = include("lib/sequence")

function play_step(self, sequence)
    local crow_output_map = {
        {cv = 1, gate = 2},
        {cv = 3, gate = 4}
    }
    local do_mirror_outputs = (self.mode == "ALTERNATING" or self.mode == "SUCCESSIVE")
    local crow_cv_out = crow_output_map[sequence.index].cv
    local crow_gate_out = crow_output_map[sequence.index].gate
    local gate, cv = sequence:play_current_step()
    if cv then
        if do_mirror_outputs then
            for i = 1, 2 do
                crow.output[crow_output_map[i].cv].volts = cv
            end
        else
            crow.output[crow_cv_out].volts = cv
        end
    end
    if gate then
        if do_mirror_outputs then
            for i = 1, 2 do
                crow.output[crow_output_map[i].gate].execute()
            end
        else
            crow.output[crow_gate_out].execute()
        end
    end
end

local function step_parallel(self)
    for _, active_sequence in ipairs(self.sequences) do
        play_step(self, active_sequence)
        active_sequence:advance(self.mode)
    end
end

local function step_successive(self)
    local active_sequence = self.sequences[self.current_sequence]
    play_step(self, active_sequence)
    local finished = active_sequence:advance(self.mode)
    if finished == true then
        if self.current_sequence == 1 then
            self.current_sequence = 2
        else
            self.current_sequence = 1
        end
    end
end

local function step_alternating(self)
    local active_sequence = self.sequences[self.current_sequence]
    play_step(self, active_sequence)
    active_sequence:advance(self.mode)
    if self.current_sequence == 1 then
        self.current_sequence = 2
    else
        self.current_sequence = 1
    end
end

function Sequencer.new()
    local s = {}
    s.modes = {
        "ALTERNATING",
        "SUCCESSIVE",
        "PARALLEL_REVERSING",
        "PARALLEL",
        "CV_DUTY",
        "CV_SLIDE",
        "CV_DUTY_RANDOM",
        "RANDOM"
    }

    s.num_sequences = 2
    s.sequences = {}
    for i = 1, s.num_sequences do
        s.sequences[i] = Sequence.new(i)
    end

    -- current_sequence is used by these modes:
    -- ALTERNATING
    -- SUCCESSIVE
    s.current_sequence = nil

    setmetatable(s, Sequencer)
    return s
end

function Sequencer:step()
    if self.mode:match("PARALLEL") then
        step_parallel(self)
    elseif self.mode == "ALTERNATING" then
        step_alternating(self)
    elseif self.mode == "SUCCESSIVE" then
        step_successive(self)
    end
end

function Sequencer:update_ui()
    for _, sequence in ipairs(self.sequences) do
        sequence:update_ui()
    end
end

function Sequencer:reset()
    for _, sequence in ipairs(self.sequences) do
        sequence:reset()
    end
end

function Sequencer:change_mode(mode_number)
    self.mode = self.modes[mode_number]
    self:reset()
    if self.mode == "SUCCESSIVE" or self.mode == "ALTERNATING" then
        self.current_sequence = 1
    else
        self.current_sequence = nil
    end
end

function Sequencer:get_sequence(idx)
    return self.sequences[idx]
end

function Sequencer:get_all_sequences()
    local seqs = {}
    for _, sequence in ipairs(self.sequences) do
        table.insert(seqs, sequence)
    end
    return seqs
end

function Sequencer:autoscroll_page(pages)
    if self.autoscroll == true and self.current_sequence then
        if pages.index ~= self.current_sequence then
            pages.index = self.current_sequence
        end
    end
end

function Sequencer:build_params()
    -- global level params on top
    -- TODO add params for:
    -- duty time, using internal/external clock, speed (if internal)
    params:add {
        type = "option",
        id = "sequencer_mode",
        name = "mode",
        options = self.modes,
        default = 4, -- default is "PARALLEL"
        action = function(value)
            self:change_mode(value)
        end
    }
    local autoscroll_options = {"ON", "OFF"}
    params:add {
        type = "option",
        id = "sequencer_autoscroll",
        name = "autoscroll",
        options = autoscroll_options,
        default = 1, -- default is "ON"
        action = function(value)
            if autoscroll_options[value] == "ON" then
                self.autoscroll = true
            else
                self.autoscroll = false
            end
        end
    }

    -- sequence and step level params
    for _, sequence in ipairs(self.sequences) do
        sequence:build_params()
    end
end

return Sequencer
