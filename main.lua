-- Music and SFX volume variables are in scripts/audio.lua
local settings = require("scripts.settings")
local dog = require("scripts.dog")
local enemy = require("scripts.enemy")
local debug_mod = require("scripts.debug")
local scenery = require("scripts.scenery")
local audio = require("scripts.audio")

function debug_print(msg)
    debug_mod.print(msg)
end

local enemies = {}
local window_width, window_height
local game_state = "play"
local game_timer = 0
local final_time = nil

-- UI ELEMENT POSITIONS (from settings)
local stats_box_x = settings.UI_STATS_BOX_X
local stats_box_y = settings.UI_STATS_BOX_Y
local stats_box_w = settings.UI_STATS_BOX_W
local stats_box_h = settings.UI_STATS_BOX_H
local stats_text_margin = settings.UI_STATS_TEXT_MARGIN

-- WIN PAGE ANIMATION SETTINGS (from settings)
local WIN_TRANSITION_TIME = settings.WIN_TRANSITION_TIME
local WIN_OVERLAY_COLOR = settings.WIN_OVERLAY_COLOR
local SCORE_FADE_COLOR = settings.SCORE_FADE_COLOR
local FINAL_SCORE_BG = settings.FINAL_SCORE_BG
local FINAL_SCORE_SHADOW = settings.FINAL_SCORE_SHADOW
local FINAL_SCORE_PADDING = settings.FINAL_SCORE_PADDING
local FINAL_SCORE_FONT_SIZE = settings.FINAL_SCORE_FONT_SIZE
local FINAL_SCORE_NUMBER_SHADOW = settings.FINAL_SCORE_NUMBER_SHADOW
local FINAL_SCORE_NUMBER_COLOR = settings.FINAL_SCORE_NUMBER_COLOR
local WIN_SCORE_TEXT_COLOR = settings.WIN_SCORE_TEXT_COLOR
local WIN_SCORE_TEXT_SHADOW = settings.WIN_SCORE_TEXT_SHADOW
local win_transition = 0 -- 0..1
local KILL_TEXT = settings.KILL_TEXT
-- Leaderboard: list of {time, score}
local leaderboard = {}
function add_leaderboard_entry(time, score)
    table.insert(leaderboard, {time=time, score=score})
    table.sort(leaderboard, function(a, b) return a.time < b.time end)
end
local sfx = require("scripts.sfx")

function reset_game()
    debug_print("[reset_game] Game reset, spawning enemies and resetting dog.")
    enemies = {}
    math.randomseed(os.time())
    for i = 1, settings.NUM_ENEMIES do
        local x = math.random(60, window_width-60)
        local y = math.random(60, window_height-60)
        table.insert(enemies, enemy.new(x, y))
    end
    dog:reset()
    game_state = "play"
    game_timer = 0
    final_time = nil
    love.mouse.setVisible(false)
    sfx.start_bkg() -- Start background SFX when game starts
end

local main_font
local font_label
local font_score
local font_btn
local font_lb_title
local font_lb_row
local popups = {}
local game_header_img

function love.load()
    debug_print("[love.load] Game loaded, initializing systems.")
    window_width, window_height = love.graphics.getDimensions()
    math.randomseed(os.time())
    love.mouse.setVisible(false)
    main_font = love.graphics.newFont("src/fonts/Minecraft.ttf", 24)
    main_font:setFilter('nearest', 'nearest')
    -- Try to load custom fonts, fallback to main_font if not found
    pcall(function() font_label = love.graphics.newFont("src/fonts/Minecraft.ttf", 26) end) ; if not font_label then font_label = main_font end
    pcall(function() font_score = love.graphics.newFont("src/fonts/Minecraft.ttf", 38) end) ; if not font_score then font_score = main_font end
    pcall(function() font_btn = love.graphics.newFont("src/fonts/Minecraft.ttf", 28) end) ; if not font_btn then font_btn = main_font end
    pcall(function() font_lb_title = love.graphics.newFont("src/fonts/Minecraft.ttf", 26) end) ; if not font_lb_title then font_lb_title = main_font end
    pcall(function() font_lb_row = love.graphics.newFont("src/fonts/Minecraft.ttf", 22) end) ; if not font_lb_row then font_lb_row = main_font end
    love.graphics.setFont(main_font)
    game_header_img = love.graphics.newImage("src/img/game_header.png")
    dog:load()
    scenery.load(window_width, window_height)
    audio.init() -- Start music (only once)
    reset_game()
end

function love.update(dt)
    audio.update() -- keep music volumes in sync
    if game_state == "win" then
        -- Animate win transition
        if win_transition < 1 then
            win_transition = math.min(1, win_transition + dt / WIN_TRANSITION_TIME)
        end
        return
    end
    win_transition = 0
    game_timer = game_timer + dt
    local mx, my = love.mouse.getPosition()
    -- Clamp dog position to allowed area (dog only)
    local header_margin_top = 18
    local header_img_h = game_header_img:getHeight()
    local stats_box_h = 98
    local window_w, window_h = love.graphics.getDimensions()
    local padding = 40
    local top_limit = header_margin_top + header_img_h + 10 + stats_box_h + 10
    -- Both dog and enemies can move anywhere within window (with padding)
    dog.x = math.max(padding, math.min(mx, window_w - padding))
    dog.y = math.max(padding, math.min(my, window_h - padding))
    dog:update(dog.x, dog.y, dt)
    for _, e in ipairs(enemies) do
        e.x = math.max(padding, math.min(e.x, window_w - padding))
        e.y = math.max(padding, math.min(e.y, window_h - padding))
        e:update(dog, dt)
    end
    -- Update popups
    for i = #popups, 1, -1 do
        local p = popups[i]
        p.y = p.y - 25 * dt
        p.alpha = p.alpha - 0.8 * dt
        p.time = p.time - dt
        if p.alpha <= 0 or p.time <= 0 then
            table.remove(popups, i)
        end
    end
    if count_remaining_enemies() == 0 then
        debug_print("[love.update] Win condition reached!")
        game_state = "win"
        final_time = game_timer
        dog.visible = false
        love.mouse.setVisible(true)
        -- Add to leaderboard (score is always NUM_ENEMIES for now)
        add_leaderboard_entry(final_time, NUM_ENEMIES)
    end
end

function love.mousepressed(x, y, button)
    debug_print("[love.mousepressed] Mouse pressed at ("..x..","..y..") button="..tostring(button)..", game_state="..tostring(game_state))
    if game_state == "win" then
        -- Must match the drawn restart button area
        local col_margin = 48
        local block_w = 220
        local block_h = 70
        local header_margin_top = 18
        local header_img_h = game_header_img:getHeight()
        local header_y = header_margin_top
        local group_y = header_y + header_img_h + 40
        local btn_x = (window_width - (block_w*2 + col_margin))/2
        local btn_y = group_y + block_h + 18
        -- (btn_x, btn_y) is left column; right column is leaderboard
        if x >= btn_x and x <= btn_x+block_w and y >= btn_y and y <= btn_y+block_h then
            debug_print("[love.mousepressed] Restart button clicked.")
            reset_game()
        end
        return
    end
    if button == 1 then
        local killed_any = false
        for _, e in ipairs(enemies) do
            if e:is_clicked(x, y) then
                debug_print("[love.mousepressed] Enemy clicked at ("..e.x..","..e.y..") state="..tostring(e.state))
                e:trigger_death()
                -- Pop-up effect
                table.insert(popups, {x=e.x, y=e.y-82, alpha=1, time=1.0, text=KILL_TEXT, color={1,1,1}})
                dog:increase_flee_range()
                dog:increase_smell_range()
                killed_any = true
            sfx.play_cat_dead() -- Play cat dead SFX
            sfx.play_dog_bark() -- Play random dog bark SFX
            end
        end
        if killed_any then
            dog:trigger_potty()
        end
    end
end

function love.draw()
    love.graphics.setFont(main_font)
    -- Background is always grass/green
    love.graphics.clear(0.18, 0.36, 0.18, 1)
    scenery.draw()

    -- Gameplay area boundaries
    local header_margin_top = 18
    local header_img_w = game_header_img:getWidth()
    local header_img_h = game_header_img:getHeight()
    local header_x = (window_width - header_img_w) / 2
    local header_y = header_margin_top
    local stats_box_w = 260
    local stats_box_h = 98
    local stats_box_x = (window_width - stats_box_w) / 2
    local stats_box_y = header_y + header_img_h + 10
    local top_limit = stats_box_y + stats_box_h + 10
    local padding = 40

    local score_y = 0
    local score_x = 0
    local score_w = 0
    local score_h = 0
    -- Draw all enemies and dog
    for _, e in ipairs(enemies) do
        e:draw()
    end
    dog:draw()
    -- Draw popups
    for _, p in ipairs(popups) do
        if p.color then
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.alpha)
        else
            love.graphics.setColor(1, 0.2, 0.2, p.alpha)
        end
        love.graphics.printf(p.text, p.x-60, p.y, 120, "center")
    end
    love.graphics.setColor(1,1,1,1)
    -- Draw win overlay if in transition
    if game_state == "win" or win_transition > 0 then
        local overlay_alpha = WIN_OVERLAY_COLOR[4] * win_transition
        love.graphics.setColor(WIN_OVERLAY_COLOR[1], WIN_OVERLAY_COLOR[2], WIN_OVERLAY_COLOR[3], overlay_alpha)
        love.graphics.rectangle("fill", 0, 0, window_width, window_height)
    end
    -- Draw header and stats board LAST (always on top)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(game_header_img, header_x, header_y)
    -- Scoreboard fades out on win
    local stats_alpha = 1 - win_transition
    local stats_text_margin = 14
    local enemies_left_str = "Enemies left: " .. count_remaining_enemies() .. "/" .. settings.NUM_ENEMIES
    local timer_str = "Time: " .. tostring(math.floor(game_timer)) .. " sec"
    if stats_alpha > 0.01 then
        love.graphics.setColor(0,0,0,0.80 * stats_alpha)
        love.graphics.rectangle("fill", stats_box_x, stats_box_y, stats_box_w, stats_box_h, 24, 24)
        love.graphics.setColor(1,1,1,0.18 * stats_alpha)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", stats_box_x+1.5, stats_box_y+1.5, stats_box_w-3, stats_box_h-3, 24, 24)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1,1,1,stats_alpha)
        love.graphics.printf(enemies_left_str, stats_box_x, stats_box_y + stats_text_margin, stats_box_w, "center")
        love.graphics.printf(timer_str, stats_box_x, stats_box_y + stats_text_margin + 34, stats_box_w, "center")
    end

    -- WIN PAGE: Only show win UI if game_state == 'win'
    if game_state == "win" then
        -- Layout constants
        local min_module_w = header_img_w + 120
        local block_w = 240
        local block_h = 56
        local block_radius = 18
        local col_margin = 56
        local leaderboard_w = 260
        local leaderboard_entry_h = 32
        local leaderboard_title_h = 38
        local total_module_w = block_w + col_margin + leaderboard_w
        if total_module_w < min_module_w then
            block_w = math.floor((min_module_w - col_margin) * 0.5)
            leaderboard_w = min_module_w - col_margin - block_w
            total_module_w = min_module_w
        end
        local win_group_top = header_y + header_img_h + 36
        local group_h = block_h*2 + 24 + 12 + leaderboard_title_h + leaderboard_entry_h*5
        local group_y = win_group_top
        local group_x = (window_width - total_module_w) / 2

        -- Left column: Round Score label, blue score box, restart button
        local score_label_y = group_y
        local score_box_y = score_label_y + 32
        local score_box_x = group_x
        local btn_x = score_box_x
        local btn_y = score_box_y + block_h + 12

        -- Draw 'Round Score' floating label
        love.graphics.setFont(font_label)
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf("Round Score", score_box_x, score_label_y, block_w, "center")

        -- Draw blue score box
        love.graphics.setColor(0.13, 0.36, 0.86, 0.97)
        love.graphics.rectangle("fill", score_box_x, score_box_y, block_w, block_h, block_radius, block_radius)
        if final_time then
            love.graphics.setFont(font_score)
            love.graphics.setColor(0,0,0,0.35)
            love.graphics.printf(string.format("%.2f s", final_time), score_box_x+2, score_box_y+block_h/2-16, block_w, "center")
            love.graphics.setColor(1,1,1,1)
            love.graphics.printf(string.format("%.2f s", final_time), score_box_x, score_box_y+block_h/2-18, block_w, "center")
        end

        -- Draw green restart button with shadow
        local btn_w = block_w
        local btn_h = block_h
        local shadow_offset = 3
        -- Shadow
        love.graphics.setColor(0.09, 0.32, 0.09, 1)
        love.graphics.rectangle("fill", btn_x+shadow_offset, btn_y+shadow_offset, btn_w, btn_h, block_radius, block_radius)
        -- Main button
        love.graphics.setColor(0.19, 0.74, 0.19, 1)
        love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, block_radius, block_radius)
        -- Button label
        love.graphics.setFont(font_btn)
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf("Restart", btn_x, btn_y+btn_h/2-14, btn_w, "center")

        -- RIGHT COLUMN: Leaderboard
        local lb_x = group_x + block_w + col_margin
        local lb_y = group_y
        love.graphics.setFont(font_lb_title)
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf("Leaderboard", lb_x, lb_y, leaderboard_w, "center")
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1,1,1,0.4)
        love.graphics.line(lb_x, lb_y+leaderboard_title_h-4, lb_x+leaderboard_w, lb_y+leaderboard_title_h-4)
        love.graphics.setFont(font_lb_row)
        for i=1,5 do
            local entry = leaderboard[i]
            local entry_y = lb_y + leaderboard_title_h + (i-1)*leaderboard_entry_h
            love.graphics.setColor(1,1,1,0.93)
            love.graphics.rectangle("fill", lb_x, entry_y, leaderboard_w, leaderboard_entry_h-4, 10, 10)
            love.graphics.setColor(0,0,0,1)
            local time_str = (entry and type(entry.time) == "number") and string.format("%6.2f", entry.time) or "--.--"
            local tstr = string.format("%d.  %s s", i, time_str)
            love.graphics.printf(tstr, lb_x+10, entry_y+4, leaderboard_w-20, "left")
        end
        love.graphics.setFont(main_font)
        return
    end
    end
    local timer_str = "Time: " .. tostring(math.floor(game_timer)) .. " sec"
    love.graphics.printf(tostring(enemies_left_str or ""), stats_box_x or 0, (stats_box_y or 0) + (stats_text_margin or 0), stats_box_w or 0, "center")
    love.graphics.printf(tostring(timer_str or ""), stats_box_x or 0, (stats_box_y or 0) + (stats_text_margin or 0) + 34, stats_box_w or 0, "center")

    if game_state == "win" then
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf("All enemies found!", 0, (window_height or 0)/2-60, window_width or 0, "center")
        if final_time ~= nil then
            love.graphics.setColor(1,1,1,1)
            local final_time_str = (type(final_time) == "number") and string.format("%.2f", final_time) or "--"
            love.graphics.printf("Final Time: " .. final_time_str .. " s", 0, (window_height or 0)/2-18, window_width or 0, "center")
        end
        -- Restart button shadow and press effect
        local btn_x = window_width/2-80
        local btn_y = window_height/2+30
        local btn_w = 160
        local btn_h = 50
        local shadow_offset = 6
        local is_pressed = love.mouse.isDown(1) and love.mouse.getX() >= btn_x and love.mouse.getX() <= btn_x+btn_w and love.mouse.getY() >= btn_y and love.mouse.getY() <= btn_y+btn_h
        if not is_pressed then
            love.graphics.setColor(0.08, 0.25, 0.08, 0.7)
            love.graphics.rectangle("fill", btn_x+shadow_offset, btn_y+shadow_offset, btn_w, btn_h, 16, 16)
        end
        love.graphics.setColor(0.2, 0.6, 0.2, 1)
        local draw_x = btn_x
        local draw_y = btn_y
        if is_pressed then
            draw_x = btn_x + shadow_offset
            draw_y = btn_y + shadow_offset
        end
        love.graphics.rectangle("fill", draw_x, draw_y, btn_w, btn_h, 16, 16)
        love.graphics.setColor(0,0,0,0.22)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", draw_x+1.5, draw_y+1.5, btn_w-3, btn_h-3, 16, 16)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf("Restart", draw_x, draw_y+15, btn_w, "center")
    love.graphics.setColor(1,1,1,1)
    -- Draw debug overlay (always last, always on top)
    debug_mod.draw(window_width, window_height)
end

function count_remaining_enemies()
    local count = 0
    for _, e in ipairs(enemies) do
        if e.state ~= "gone" and e.state ~= "dead_hold" and e.state ~= "dead_fade" then
            count = count + 1
        end
    end
    return count
end
