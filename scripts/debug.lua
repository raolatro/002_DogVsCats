-- debug.lua: simple debug overlay system
local debug_mod = {}

DEBUG_ENABLED = false -- Global toggle for debug overlay

local max_lines = 32
local debug_lines = {}
local debug_font = love.graphics.newFont(10)
debug_font:setFilter('nearest', 'nearest')

function debug_mod.print(msg)
    table.insert(debug_lines, msg)
    if #debug_lines > max_lines then
        table.remove(debug_lines, 1)
    end
end

function debug_mod.clear()
    debug_lines = {}
end

function debug_mod.draw(window_width, window_height)
    if not DEBUG_ENABLED then return end
    love.graphics.setFont(debug_font)
    love.graphics.setColor(1, 0, 0, 1)
    local margin = 8
    local line_height = debug_font:getHeight()
    for i = 1, #debug_lines do
        local text = debug_lines[i]
        love.graphics.print(text, margin, margin + (i-1) * line_height)
    end
    love.graphics.setColor(1,1,1,1)
end

return debug_mod
