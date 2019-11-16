local function create_step_value_params(sequence)
    params:add_separator()
    local linear_volts_cs = controlspec.new(0, 5, "lin", 0, 0, "volts")
    for _, step in ipairs(sequence.steps) do
        params:add {
            type = "control",
            id = sequence.index .. "_" .. "step_" .. step.index .. "_value",
            name = "seq " .. sequence.name .. ": " .. "step " .. step.index .. " value",
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
            id = sequence.index .. "_" .. "step_" .. step.index .. "_active",
            name = "seq " .. sequence.name .. ": " .. "step " .. step.index .. " active",
            options = {"OFF", "ON"},
            default = 2,
            action = function(value)
                step.toggle:toggle()
            end
        }
    end
end

local function create_sequence_params(sequence)
    params:add {
        type = "option",
        id = sequence.index .. "_" .. "cv_range",
        name = "seq " .. sequence.name .. ": " .. "cv range",
        options = {"1V", "2V", "5V", "8V"},
        default = 1,
        action = function(value)
            -- rework existing param ranges
        end
    }
    params:add {
        type = "option",
        id = sequence.index .. "_" .. "cv_behavior",
        name = "seq " .. sequence.name .. ": " .. "cv behavior",
        options = {"LINEAR", "MINOR", "MAJOR", "CHROMATIC"},
        default = 1,
        action = function(value)
            -- remap param outputs
        end
    }
end

local function param_id_for_step_value(sequence, step_num)
    return sequence.index .. "_" .. "step_" .. step_num .. "_value"
end

local function param_id_for_step_active(sequence, step_num)
    return sequence.index .. "_" .. "step_" .. step_num .. "_active"
end

return {
    create_step_value_params = create_step_value_params,
    create_step_active_params = create_step_active_params,
    create_sequence_params = create_sequence_params,
    param_id_for_step_value = param_id_for_step_value,
    param_id_for_step_active = param_id_for_step_active
}
