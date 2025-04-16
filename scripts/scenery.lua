-- scenery.lua: handles grass background tile logic
local scenery = {}

local TILE_SIZE = 48
local grass_images = {}
local grass_count = 6
local grid = {}
local grid_width, grid_height

function scenery.load(window_width, window_height)
    -- Load all 6 grass images
    for i=1,grass_count do
        grass_images[i] = love.graphics.newImage(string.format("src/sprites/grass/grass%d.png", i))
    end
    -- Calculate grid size
    grid_width = math.ceil(window_width / TILE_SIZE)
    grid_height = math.ceil(window_height / TILE_SIZE)
    -- Generate grid with random grass, never repeating horizontally and with random empty spots
    grid = {}
    for y=1,grid_height do
        grid[y] = {}
        for x=1,grid_width do
            local available = {0} -- 0 means empty
            -- Only allow empty if left neighbor is not empty
            if x > 1 and grid[y][x-1] and grid[y][x-1].idx == 0 then
                available = {}
            end
            for i=1,grass_count do
                -- Don't allow same as left neighbor
                if not (x > 1 and grid[y][x-1] and grid[y][x-1].idx == i) then
                    table.insert(available, i)
                end
            end
            -- Randomly choose empty spot (about 1 in 7 chance)
            local idx
            if #available > 1 and math.random() < 1/7 then
                idx = 0
            else
                if #available == 0 then available = {1} end
                idx = available[math.random(#available)]
            end
            -- Assign a static offset per grass tile
            local ox = ((math.random() - 0.5) * TILE_SIZE)
            local oy = ((math.random() - 0.5) * TILE_SIZE)
            local flip_x = math.random() < 0.5
            grid[y][x] = {idx=idx, ox=ox, oy=oy, flip_x=flip_x}
        end
    end
    -- (Optional: could also check vertical adjacency for empty, but keeping simple for now)
end

function scenery.draw()
    for y=1,grid_height do
        for x=1,grid_width do
            local cell = grid[y][x]
            if cell.idx ~= 0 then
                local img = grass_images[cell.idx]
                local draw_x = (x-1)*TILE_SIZE + cell.ox
                local draw_y = (y-1)*TILE_SIZE + cell.oy
                if cell.flip_x then
                    love.graphics.draw(img, draw_x + TILE_SIZE, draw_y, 0, -1, 1)
                else
                    love.graphics.draw(img, draw_x, draw_y, 0, 1, 1)
                end
            end
        end
    end
end

return scenery
