local UI = {}
UI.__index = UI

UI.Button = {}
UI.Button.__index = UI.Button

function UI.Button.new(x, y, w, h)
    local button = {
        x = x or 0,
        y = y or 0,
        w = w or 8,
        h = h or 8,
        fill = true,
        active = true
    }
    setmetatable(UI.Button, {__index = UI})
    setmetatable(button, UI.Button)
    return button
end

function UI.Button:toggle()
    self.active = not self.active
end

function UI.Button:redraw()
    if self.active then
        screen.level(15)
    else
        screen.level(5)
    end
    screen.rect(self.x, self.y, self.w, self.h)
    if self.fill then
        screen.fill()
    else
        screen.stroke()
    end
end

return UI
