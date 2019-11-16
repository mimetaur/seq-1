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

local function create_step_value_params(sequence)
    params:add_separator()

    local cv_id, cv_name = param_for_cv_range(sequence)
    local cv_range = params:get(cv_id)
    local max_volts = 8.0
    if cv_range == 1 then
        max_volts = 1.0
    elseif cv_range == 2 then
        max_volts = 2.0
    elseif cv_range == 3 then
        max_volts = 5.0
    end

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
    local ri, rn = param_for_cv_range(sequence)
    params:add {
        type = "option",
        id = ri,
        name = rn,
        options = {"1V", "2V", "5V", "8V"},
        default = 1,
        action = function(value)
            sequence:set_cv_range(value)
            -- rework existing param ranges
        end
    }
    local bi, bn = param_for_cv_behavior(sequence)
    params:add {
        type = "option",
        id = bi,
        name = bn,
        options = {"LINEAR", "MINOR", "MAJOR", "CHROMATIC"},
        default = 1,
        action = function(value)
            -- remap param outputs
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
