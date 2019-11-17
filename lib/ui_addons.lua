local UI = {}
UI.__index = UI

UI.Toggle = {}
UI.Toggle.__index = UI.Toggle

function UI.Toggle.new(x, y, w, h, on, lo, hi)
    local toggle = {
        x = x or 0,
        y = y or 0,
        w = w or 8,
        h = h or 8,
        on = on or true,
        active = true,
        lo = lo or 5,
        hi = hi or 15
    }
    setmetatable(UI.Toggle, {__index = UI})
    setmetatable(toggle, UI.Toggle)
    return toggle
end

function UI.Toggle:toggle()
    self.on = not self.on
end

function UI.Toggle:turn_on()
    self.on = true
end

function UI.Toggle:turn_off()
    self.on = false
end

function UI.Toggle:redraw()
    if self.active then
        screen.level(self.hi)
    else
        screen.level(self.lo)
    end
    screen.rect(self.x, self.y, self.w, self.h)
    if self.on then
        screen.fill()
    else
        screen.stroke()
    end
end

return UI
