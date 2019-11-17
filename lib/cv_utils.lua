-- credit to s wolk for quantizer
-- https://github.com/monome/bowery/blob/master/quantizer.lua

-- nb: scales should be written as semitones (cents optional) in ascending order
-- TODO see if these can just be pulled in from the music utils library
local scales = {
    octaves = {0, 12},
    major = {0, 2, 4, 5, 7, 9, 11, 12},
    dorian = {0, 2, 3, 5, 7, 9, 10, 12},
    majorTriad = {0, 4, 7, 12},
    dominant7th = {0, 4, 7, 10, 12},
    harmonicMinor = {0, 2, 3, 5, 7, 8, 10, 12},
    chromatic = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
}

local function n2v(note)
    return note / 12
end

local function quantize(volts, scale)
    local octave = math.floor(volts)
    local interval = volts - octave
    local semitones = interval / (n2v(1))
    local degree = 1
    while degree < #scale and semitones > scale[degree + 1] do
        degree = degree + 1
    end
    local above = scale[degree + 1] - semitones
    local below = semitones - scale[degree]
    if below > above then
        degree = degree + 1
    end
    local note = scale[degree]
    note = note + (12 * octave)
    return note
end

return {
    scales = scales,
    quantize = quantize,
    n2v = n2v
}
