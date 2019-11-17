-- TODO refactor this entire module
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

local function param_id_for_step_value(sequence, step_num)
    return "seq_" .. sequence.index .. "_" .. "step_" .. step_num .. "_value"
end

local function param_name_for_step_value(sequence, step_num)
    return "seq " .. sequence.name .. ": " .. "step " .. step_num .. " value"
end

local function param_id_for_step_active(sequence, step_num)
    return "seq_" .. sequence.index .. "_" .. "step_" .. step_num .. "_active"
end

local function param_name_for_step_active(sequence, step_num)
    return "seq " .. sequence.name .. ": " .. "step " .. step_num .. " active"
end

local function param_for_cv_range(sequence)
    return "seq_" .. sequence.index .. "_" .. "cv_range", "seq " .. sequence.name .. ": " .. "cv range"
end

local function param_for_cv_behavior(sequence)
    return "seq_" .. sequence.index .. "_" .. "cv_behavior", "seq " .. sequence.name .. ": " .. "cv behavior"
end

local function param_for_octave(sequence)
    return "seq_" .. sequence.index .. "_" .. "octave", "seq " .. sequence.name .. ": " .. "octave"
end

local function create_step_value_params(sequence)
    params:add_separator()

    local cv_id, cv_name = param_for_cv_range(sequence)
    local max_volts = CV_RANGE_VOLTAGES[params:get(cv_id)]

    local linear_volts_cs = controlspec.new(0, max_volts, "lin", 0, 0, "volts")
    for _, step in ipairs(sequence.steps) do
        params:add {
            type = "control",
            id = param_id_for_step_value(sequence, step.index),
            name = param_name_for_step_value(sequence, step.index),
            controlspec = linear_volts_cs,
            action = function(value)
                step.slider:set_value(value)
            end
        }
    end
end

local function create_step_active_params(sequence)
    -- TODO there is both step active
    -- AND gate on the SQ-1
    -- so there needs to also be a gate param
    params:add_separator()
    for _, step in ipairs(sequence.steps) do
        params:add {
            type = "option",
            id = param_id_for_step_active(sequence, step.index),
            name = param_name_for_step_active(sequence, step.index),
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
    end
end

local function create_sequence_params(sequence)
    params:add_separator()
    local ri, rn = param_for_cv_range(sequence)
    params:add {
        type = "option",
        id = ri,
        name = rn,
        options = CV_RANGE_OPTIONS,
        default = 1,
        action = function(value)
            local voltage = CV_RANGE_VOLTAGES[value]
            sequence:set_cv_range(voltage)
        end
    }
    local bi, bn = param_for_cv_behavior(sequence)
    params:add {
        type = "option",
        id = bi,
        name = bn,
        options = CV_BEHAVIOR_OPTIONS,
        default = 1,
        action = function(value)
            local scale = CV_BEHAVIOR_SCALES[value]
            sequence.scale = scale
        end
    }

    local oi, on = param_for_octave(sequence)
    local octaves = {"0", "1", "2", "3", "4", "5"}
    params:add {
        type = "option",
        id = oi,
        name = on,
        options = octaves,
        default = 1,
        action = function(value)
            sequence.octave = tonumber(octaves[value])
        end
    }
end

return {
    create_step_value_params = create_step_value_params,
    create_step_active_params = create_step_active_params,
    create_sequence_params = create_sequence_params,
    param_id_for_step_value = param_id_for_step_value,
    param_name_for_step_value = param_name_for_step_value,
    param_id_for_step_active = param_id_for_step_active,
    param_name_for_step_active = param_name_for_step_active
}
