-- seq-1
-- an SQ-1 for norns
--

function init()
	crow.ii.pullup(true)
end

function enc(n, d)
	print(n .. "," .. d)
	redraw()
end

function key(n, z)
	print(n .. "," .. z)
	redraw()
end

function redraw()
	screen.clear()

	screen.level(9)
	screen.move(6, 12)
	screen.text("seq-1")

	screen.update()
end
