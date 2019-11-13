local UI = require "ui"

local step_seq_ui = {}
step_seq_ui.LEVEL_HI = 12
step_seq_ui.LEVEL_MED = 8
step_seq_ui.LEVEL_LO = 6

function step_seq_ui.create_layout(x, y, sw, sh, xs, ys, bw, bh, hs, hw, hh)
    local layout = {}
    layout.x_offset = x or 6
    layout.y_offset = y or 10
    layout.slider_w = sw or 8
    layout.slider_h = sh or 36
    layout.x_space = xs or 6
    layout.y_space = ys or 4

    layout.button_w = bw or layout.slider_w
    layout.button_h = bh or math.floor(layout.slider_h * 0.2)

    layout.highlight_spacer = hs or 6
    layout.highlight_width = hw or layout.slider_w
    layout.highlight_height = hh or 2

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

    layout.buttons = {}
    for i = 1, 8 do
        layout.buttons[i] = {}
        layout.buttons[i].x = layout.x_offset + ((i - 1) * (layout.button_w + layout.x_space))
        layout.buttons[i].y = layout.y_offset + layout.slider_h + layout.y_space
    end
    return layout
end

function step_seq_ui.create_slider(step_num, layout)
    local slider_x = layout.sliders[step_num].x
    local slider_y = layout.sliders[step_num].y
    local slider_w = layout.slider_w
    local slider_h = layout.slider_h

    return UI.Slider.new(slider_x, slider_y, slider_w, slider_h, 0, 0, 5)
end

function step_seq_ui.create_button(step_num, layout)
    local btn_x = layout.buttons[step_num].x
    local btn_y = layout.buttons[step_num].y
    local btn_w = layout.button_w
    local btn_h = layout.button_h
    local btn = {x = btn_x, y = btn_y, w = btn_w, h = btn_h, active = false, gate_on = true}
    return btn
end

function step_seq_ui.create_highlight(step_num, layout)
    local hl_x = layout.highlights[step_num].x
    local hl_y = layout.highlights[step_num].y
    local hl_w = layout.highlight_width
    local hl_h = layout.highlight_height
    local highlight = {x = hl_x, y = hl_y, w = hl_w, h = hl_h, active = false}
    return highlight
end

function step_seq_ui.draw_button(step)
    if step.button.active == true then
        screen.level(step_seq_ui.LEVEL_HI)
    else
        screen.level(step_seq_ui.LEVEL_LO)
    end
    screen.rect(step.button.x, step.button.y, step.button.w, step.button.h)
    if step.active then
        screen.fill()
    else
        screen.stroke()
    end
end

function step_seq_ui.draw_highlight(step)
    if step.highlight.active == true then
        screen.level(step_seq_ui.LEVEL_HI)
    else
        screen.level(step_seq_ui.LEVEL_LO)
    end
    screen.rect(step.highlight.x, step.highlight.y, step.highlight.w, step.highlight.h)
    screen.fill()
end

function step_seq_ui.draw_sequence_name(name)
    screen.level(step_seq_ui.LEVEL_MED)
    screen.move(120, 8)
    screen.text(name)
end

function step_seq_ui.draw_ui(steps, name)
    for num, step in ipairs(steps) do
        step.slider:redraw()
        step_seq_ui.draw_button(step)
        step_seq_ui.draw_highlight(step)
    end

    step_seq_ui.draw_sequence_name(name)
end

function step_seq_ui.update_slider(step, new_value)
    step.slider:set_value(new_value)
end

function step_seq_ui.update_active_ui_elements(steps, active_step_index)
    for i, step in ipairs(steps) do
        if i == active_step_index then
            step.slider.active = true
            step.button.active = true
            step.highlight.active = true
        else
            step.slider.active = false
            step.button.active = false
            step.highlight.active = false
        end
    end
end

return step_seq_ui
