local CV_RANGE_OPTIONS = {"1V", "2V", "5V", "8V"}
local CV_RANGE_VOLTAGES = {1, 2, 5, 8}

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
    local max_volts = CV_RANGE_VOLTAGES[params:get(cv_id)]
    print(max_volts)

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
            for _, step in ipairs(sequence.steps) do
                local param = params:lookup_param(param_id_for_step_value(sequence, step.index))
                param.controlspec.maxval = voltage
            end
            sequence:set_cv_range(voltage)
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
            -- TODO implement this so it dynamically remaps the output voltages
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
