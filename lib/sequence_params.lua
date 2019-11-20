local CV_UTILS = include("lib/cv_utils")

local CV_RANGE_OPTIONS = {"1V", "2V", "5V", "8V"}
local CV_RANGE_VOLTAGES = {1, 2, 5, 8}
local CV_RANGE_REV_LOOKUP = {}
CV_RANGE_REV_LOOKUP[1] = 1
CV_RANGE_REV_LOOKUP[2] = 2
CV_RANGE_REV_LOOKUP[5] = 3
CV_RANGE_REV_LOOKUP[8] = 4

local CV_BEHAVIOR_OPTIONS = {"LINEAR", "MINOR", "MAJOR", "CHROMATIC"}
local CV_BEHAVIOR_SCALES = {nil, CV_UTILS.scales.harmonicMinor, CV_UTILS.scales.major, CV_UTILS.scales.chromatic}

local OCTAVES = {"0", "1", "2", "3", "4", "5"}

local function build_step_cv_params(sequence)
    params:add_separator()
    local max_volts = CV_RANGE_VOLTAGES[params:get(sequence.params.cv_range)]
    local linear_volts_cs = controlspec.new(0, max_volts, "lin", 0, 0, "volts")
    for _, step in ipairs(sequence.steps) do
        local param_id = "seq_" .. sequence.index .. "_" .. "step_" .. step.index .. "_cv"
        local param_name = "seq " .. sequence.name .. ": " .. "step " .. step.index .. " cv"

        params:add {
            type = "control",
            id = param_id,
            name = param_name,
            controlspec = linear_volts_cs,
            action = function(value)
                step.slider:set_value(value)
            end
        }
        step.params.cv = param_id
    end
end

local function build_step_gate_params(sequence)
    -- TODO there is both step active
    -- AND gate on the SQ-1
    -- so there needs to also be a step active param
    params:add_separator()
    for _, step in ipairs(sequence.steps) do
        local param_id = "seq_" .. sequence.index .. "_" .. "step_" .. step.index .. "_gate"
        local param_name = "seq " .. sequence.name .. ": " .. "step " .. step.index .. " gate"
        params:add {
            type = "option",
            id = param_id,
            name = param_name,
            options = {"OFF", "ON"},
            default = 2,
            action = function(value)
                if value == 1 then
                    step.toggle:turn_off()
                elseif value == 2 then
                    step.toggle:turn_on()
                end
            end
        }
        step.params.gate = param_id
    end
end

local function build_sequence_params(sequence)
    params:add_separator()

    local cv_range_param_id = "seq_" .. sequence.index .. "_" .. "cv_range"
    local cv_range_param_name = "seq " .. sequence.name .. ": " .. "cv range"
    params:add {
        type = "option",
        id = cv_range_param_id,
        name = cv_range_param_name,
        options = CV_RANGE_OPTIONS,
        default = 1,
        action = function(value)
            local voltage = CV_RANGE_VOLTAGES[value]
            sequence:set_cv_range(voltage)
        end
    }
    sequence.params.cv_range = cv_range_param_id

    local cv_behavior_param_id = "seq_" .. sequence.index .. "_" .. "cv_behavior"
    local cv_behavior_param_name = "seq " .. sequence.name .. ": " .. "cv behavior"
    params:add {
        type = "option",
        id = cv_behavior_param_id,
        name = cv_behavior_param_name,
        options = CV_BEHAVIOR_OPTIONS,
        default = 1,
        action = function(value)
            local scale = CV_BEHAVIOR_SCALES[value]
            sequence.scale = scale
        end
    }
    sequence.params.cv_behavior = cv_behavior_param_id

    local octave_param_id = "seq_" .. sequence.index .. "_" .. "octave"
    local octave_param_name = "seq " .. sequence.name .. ": " .. "octave"
    params:add {
        type = "option",
        id = octave_param_id,
        name = octave_param_name,
        options = OCTAVES,
        default = 1,
        action = function(value)
            local octave = tonumber(OCTAVES[value])
            sequence.octave = octave
        end
    }
    sequence.params.octave = octave_param_id
end

return {
    build_step_cv_params = build_step_cv_params,
    build_step_gate_params = build_step_gate_params,
    build_sequence_params = build_sequence_params
}
