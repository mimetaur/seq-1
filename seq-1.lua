-- seq-1
-- an SQ-1 for norns
--
-- ENC1 selects a sequence
-- ENC2 selects a step
-- ENC3 changes step value
--
-- KEY2 toggles step on/off
-- KEY3 TBD (fine-tune?)

--

-- TODO add top level options like direction, speed, internal/external clock, gate on, active steps etc.
-- see everything in the sequencer level block in the manual

local UI = require "ui"
local Sequence = include("lib/sequence")

local pages, sequences
local sequencer = {
	modes = {
		"ALTERNATING",
		"SUCCESSIVE",
		"PARALLEL_REV",
		"PARALLEL",
		"CV_DUTY",
		"CV_SLIDE",
		"CV_DUTY_RAND",
		"RANDOM"
	},
	current_sequence = 1,
	num_sequences = 2
}

local function play_step_of_sequence(sequence, play_all)
	local play_all_outputs = play_all or false

	local crow_outputs = {
		{cv = 1, gate = 2},
		{cv = 3, gate = 4}
	}
	local crow_cv_out = crow_outputs[sequence.index].cv
	local crow_gate_out = crow_outputs[sequence.index].gate

	local gate, cv = sequence:play_current_step()
	if cv then
		if play_all_outputs then
			for i = 1, 2 do
				crow.output[crow_outputs[i].cv].volts = cv
			end
		else
			crow.output[crow_cv_out].volts = cv
		end
	end
	if gate then
		if play_all_outputs then
			for i = 1, 2 do
				crow.output[crow_outputs[i].gate].execute()
			end
		else
			crow.output[crow_gate_out].execute()
		end
	end
end

local function step_parallel(mode)
	for i = 1, sequencer.num_sequences do
		local sequence = sequences[i]
		play_step_of_sequence(sequence)
		sequence:advance(mode)
	end
end

local function step_successive(mode)
	local sequence = sequences[sequencer.current_sequence]
	play_step_of_sequence(sequence, true)

	local finished = sequence:advance(mode)
	if finished == true then
		if sequencer.current_sequence == 1 then
			sequencer.current_sequence = 2
		else
			sequencer.current_sequence = 1
		end
	end
end

local function step()
	local autoscroll = params:string("sequencer_autoscroll")
	local mode = params:string("sequencer_mode")
	if mode == "PARALLEL" or mode == "PARALLEL_REV" then
		step_parallel(mode)
	elseif mode == "SUCCESSIVE" then
		step_successive(mode)
		if autoscroll == "ON" then
			if pages.index ~= sequencer.current_sequence then
				pages.index = sequencer.current_sequence
			end
		end
	end
	sequences[pages.index]:update_ui()
	redraw()
end

local function remap_sequence_level_params(leader_seq, follower_seq)
	local voltage = leader_seq:get_cv_range()
	follower_seq:set_cv_range_param(voltage)

	local behavior_idx, bo, bs = leader_seq:get_cv_behavior()
	follower_seq:set_cv_behavior_param(behavior_idx)

	local octave = leader_seq:get_octave()
	follower_seq:set_octave_param(octave)
end

function init()
	pages = UI.Pages.new(1, 2)

	sequences = {}
	for i = 1, sequencer.num_sequences do
		sequences[i] = Sequence.new(i)
	end

	crow.ii.pullup(true)
	-- crow input 1 is a clock requiring triggers
	crow.input[1].mode("change", 1, 0.1, "rising")
	crow.input[1].change = step

	-- crow input 2 is a reset requiring a trigger
	crow.input[2].mode("change", 1, 0.1, "rising")

	-- crow output 1 and 3 are cv
	crow.output[1].slew = 0
	crow.output[1].volts = 0

	crow.output[3].slew = 0
	crow.output[3].volts = 0

	-- crow output 2 and 4 are gates/triggers
	crow.output[2].slew = 0
	crow.output[2].action = "pulse(0.1,5,1)"
	crow.output[4].slew = 0
	crow.output[4].action = "pulse(0.1,5,1)"

	params:add {
		type = "option",
		id = "sequencer_mode",
		name = "mode",
		options = sequencer.modes,
		default = 4,
		action = function(value)
			if sequencer.modes[value] == "SUCCESSIVE" then
				sequencer.current_sequence = 1
				remap_sequence_level_params(sequences[1], sequences[2])
			else
				for _, sequence in ipairs(sequences) do
					sequence:reset()
				end
			end
		end
	}

	params:add {
		type = "option",
		id = "sequencer_autoscroll",
		name = "autoscroll",
		options = {"ON", "OFF"},
		default = 1
	}

	for _, sequence in ipairs(sequences) do
		sequence:build_params()
	end

	params:default()
end

function enc(n, delta)
	if n == 1 then
		pages:set_index_delta(delta, false)
		sequences[pages.index]:update_ui()
	elseif n == 2 then
		sequences[pages.index]:select_step_by_delta(delta)
		sequences[pages.index]:update_ui()
	elseif n == 3 then
		sequences[pages.index]:set_selected_step_value_by_delta(delta)
	end
	redraw()
end

function key(n, z)
	if n == 2 and z == 1 then
		sequences[pages.index]:toggle_selected_step()
	end
	redraw()
end

function redraw()
	screen.clear()
	pages:redraw()
	sequences[pages.index]:draw()
	screen.update()
end
