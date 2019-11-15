local UI = require "ui"
local UI_Addons = include("lib/ui_addons")

local LEVEL_HI = 12
local LEVEL_MED = 8
local LEVEL_LO = 6

local function create_layout(x, y, sw, sh, xs, ys, bw, bh, hs, hw, hh)
    local layout = {}
    layout.x_offset = x or 6
    layout.y_offset = y or 10
    layout.slider_w = sw or 8
    layout.slider_h = sh or 36
    layout.x_space = xs or 6
    layout.y_space = ys or 4

    layout.toggle_w = bw or layout.slider_w
    layout.toggle_h = bh or math.floor(layout.slider_h * 0.2)

    layout.highlight_spacer = hs or 6
    layout.highlight_width = hw or layout.slider_w
    layout.highlight_height = hh or 2

    layout.name_x = 120
    layout.name_y = 8

    layout.sliders = {}
    for i = 1, 8 do
        layout.sliders[i] = {}
        layout.sliders[i].x = layout.x_offset + ((i - 1) * (layout.slider_w + layout.x_space))
        layout.sliders[i].y = layout.y_offset
    end

    layout.highlights = {}
    for i = 1, 8 do
        layout.highlights[i] = {}
        layout.highlights[i].x = layout.sliders[i].x
        layout.highlights[i].y = layout.sliders[i].y - layout.highlight_spacer
    end

    layout.toggles = {}
    for i = 1, 8 do
        layout.toggles[i] = {}
        layout.toggles[i].x = layout.x_offset + ((i - 1) * (layout.toggle_w + layout.x_space))
        layout.toggles[i].y = layout.y_offset + layout.slider_h + layout.y_space
    end
    return layout
end

local function create_slider(step_num, layout)
    local slider_x = layout.sliders[step_num].x
    local slider_y = layout.sliders[step_num].y
    local slider_w = layout.slider_w
    local slider_h = layout.slider_h

    return UI.Slider.new(slider_x, slider_y, slider_w, slider_h, 0, 0, 5)
end

local function create_toggle(step_num, layout)
    local tog_x = layout.toggles[step_num].x
    local tog_y = layout.toggles[step_num].y
    local tog_w = layout.toggle_w
    local tog_h = layout.toggle_h
    local is_on = true
    local btn = UI_Addons.Toggle.new(tog_x, tog_y, tog_w, tog_h, is_on)
    return btn
end

local function create_highlight(step_num, layout)
    local hl_x = layout.highlights[step_num].x
    local hl_y = layout.highlights[step_num].y
    local hl_w = layout.highlight_width
    local hl_h = layout.highlight_height
    local highlight = UI_Addons.Toggle.new(hl_x, hl_y, hl_w, hl_h)
    return highlight
end

local function update_steps(steps, selected_idx)
    for i, step in ipairs(steps) do
        step.slider.active = false
        step.toggle.active = false
        step.highlight.active = false
        if i == selected_idx then
            step.slider.active = true
            step.toggle.active = true
            step.highlight.active = true
        end
    end
end

local function draw_highlight(step)
    if step.highlight.active == true then
        screen.level(LEVEL_HI)
    else
        screen.level(LEVEL_LO)
    end
    screen.rect(step.highlight.x, step.highlight.y, step.highlight.w, step.highlight.h)
    screen.fill()
end

local function draw_name(name, x, y)
    screen.level(LEVEL_MED)
    screen.move(x, y)
    screen.text(name)
end

return {
    draw_name = draw_name,
    update_steps = update_steps,
    create_highlight = create_highlight,
    create_toggle = create_toggle,
    create_slider = create_slider,
    create_layout = create_layout
}
