-- enemy.lua: enemy logic
local settings = require("scripts.settings")
local utils = require("scripts.utils")
local enemy_anim = require("scripts.enemy_anim")

local enemy = {}
enemy.__index = enemy

local SPRITE_SIZE = settings.ENEMY_SPRITE_SIZE
local IDLE_FRAMES = settings.ENEMY_IDLE_FRAMES
local ATTACK_FRAMES = settings.ENEMY_ATTACK_FRAMES
local DEATH_FRAMES = settings.ENEMY_DEATH_FRAMES
local WALK_FRAMES = settings.ENEMY_WALK_FRAMES
local WALK_DISTANCE = settings.ENEMY_WALK_DISTANCE
local WALK_SPEED = settings.ENEMY_WALK_SPEED
local CAT_CHASE_SPEED = settings.ENEMY_CAT_CHASE_SPEED
local FLEE_DIFFICULTY = settings.ENEMY_FLEE_DIFFICULTY
local FLEE_SPEED = settings.ENEMY_FLEE_SPEED
local ENEMIES_ALWAYS_VISIBLE = settings.ENEMIES_ALWAYS_VISIBLE
local ENEMIES_IDLE_DURATION_MAX = settings.ENEMIES_IDLE_DURATION_MAX

function enemy.new(x, y, radius)
    local self = setmetatable({}, enemy)
    self.x = x
    self.base_x = x
    self.y = y
    self.radius = radius or 24
    self.visible = false
    self.death_timer = 0
    self.state = "idle" -- idle, walk_left, walk_right, dying, dead, dead_hold, dead_fade, gone
    self.anim_idle = enemy_anim.new(settings.SPRITE_ENEMY_IDLE, IDLE_FRAMES, settings.ENEMY_IDLE_FRAME_TIME)
    self.anim_attack = enemy_anim.new(settings.SPRITE_ENEMY_ATTACK, ATTACK_FRAMES, settings.ENEMY_ATTACK_FRAME_TIME)
    self.anim_walk = enemy_anim.new(settings.SPRITE_ENEMY_WALK, WALK_FRAMES, settings.ENEMY_WALK_FRAME_TIME)
    self.anim_death = enemy_anim.new(settings.SPRITE_ENEMY_DEATH, DEATH_FRAMES, settings.ENEMY_DEATH_FRAME_TIME)
    -- Randomly flip enemy at spawn (50/50)
    if math.random() < 0.5 then
        self.flip = true
        self.last_walk_dir = -1
    else
        self.flip = false
        self.last_walk_dir = 1
    end
    self.walk_timer = math.random(0.5, ENEMIES_IDLE_DURATION_MAX)
    self.walk_dir = 1 -- 1 = right, -1 = left
    self.walk_phase = 0 -- 0 = idle, 1 = walking
    return self
end

function enemy:update(dog, dt)
    local was_visible = self.visible
    -- Always visible for opacity logic
    self.visible = true
    -- Distance to dog for opacity
    self.dist_to_dog = utils.distance(self.x, self.y, dog.x, dog.y)
    self.smell_range = dog.smell_range
    self.flee_range = dog.flee_range
    local in_flee = self.dist_to_dog <= self.flee_range
    -- Flee if in flee_range and not dying/dead
    if (self.state == "idle" or self.state == "walk_left" or self.state == "walk_right" or self.state == "attack") and in_flee then
        -- Flee state: use walk animation and move away at increased speed
        if self.state ~= "walk_left" and self.state ~= "walk_right" then
            self.state_before_attack = self.state
            -- Pick direction for walk anim
            if dog.x < self.x then
                self.state = "walk_right"
            else
                self.state = "walk_left"
            end
        end
        -- Flee speed is constant regardless of kills
        local flee_speed_math = FLEE_SPEED
        -- Move AWAY from dog
        local dx = self.x - dog.x
        local dy = self.y - dog.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 1 then
            self.x = self.x + (dx/dist) * flee_speed_math * dt
            self.y = self.y + (dy/dist) * flee_speed_math * dt
        end
        -- Always face away from dog
        self.flip = dog.x > self.x
        self.anim_walk:update(dt)
        return
    elseif self.state == "attack" and not in_smell then
        -- Resume previous walk/idle state
        self.state = self.state_before_attack or "idle"
    end
    -- Walking logic
    if self.state == "idle" or self.state == "walk_left" or self.state == "walk_right" then
        -- Walking phase machine
        if not self.walk_phase or self.walk_phase == 0 then
            -- Idle phase
            self.walk_timer = self.walk_timer - dt
            self.anim_idle:update(dt)
            if self.walk_timer <= 0 then
                if not self.last_walk_dir or self.last_walk_dir == 1 then
                    self.state = "walk_left"
                    self.walk_phase = 1
                    self.walk_timer = 0.4
                    self.walk_target = self.base_x - math.random(WALK_DISTANCE, WALK_DISTANCE)
                    self.last_walk_dir = -1
                else
                    self.state = "walk_right"
                    self.walk_phase = 1
                    self.walk_timer = 0.4
                    self.walk_target = self.base_x + math.random(WALK_DISTANCE, WALK_DISTANCE)
                    self.last_walk_dir = 1
                end
            end
        elseif self.walk_phase == 1 then
            -- Walking phase
            local speed = WALK_SPEED -- px/sec
            if self.state == "walk_left" then
                self.flip = true
                self.x = self.x - speed * dt
                if self.x <= self.walk_target then
                    self.x = self.walk_target
                    self.state = "idle"
                    self.walk_phase = 0
                    self.walk_timer = math.random(0.5, ENEMIES_IDLE_DURATION_MAX)
                end
            elseif self.state == "walk_right" then
                self.flip = false
                self.x = self.x + speed * dt
                if self.x >= self.walk_target then
                    self.x = self.walk_target
                    self.state = "idle"
                    self.walk_phase = 0
                    self.walk_timer = math.random(0.5, ENEMIES_IDLE_DURATION_MAX)
                end
            end
            self.anim_walk:update(dt)
        end
    elseif self.state == "dying" then
        self.anim_death:update(dt)
        -- When the death animation completes a full loop, mark as dead_hold
        if self.anim_death.base.current_frame == self.anim_death.base.frame_count then
            self._death_anim_on_last = true
        elseif self._death_anim_on_last and self.anim_death.base.current_frame == 1 then
            self.state = "dead_hold"
            self.dead_hold_timer = 1.0
            self._death_anim_on_last = false
        end
    elseif self.state == "dead_hold" then
        self.dead_hold_timer = self.dead_hold_timer - dt
        if self.dead_hold_timer <= 0 then
            self.state = "dead_fade"
            self.dead_fade_timer = 0.5
        end
    elseif self.state == "dead_fade" then
        self.dead_fade_timer = self.dead_fade_timer - dt
        if self.dead_fade_timer <= 0 then
            self.state = "gone"
        end
    end
end

function enemy:is_clicked(mx, my)
    local can_be_killed = (self.state == "idle" or self.state == "walk_left" or self.state == "walk_right" or self.state == "attack")
    local clicked = self.visible and can_be_killed and utils.distance(self.x, self.y, mx, my) <= self.radius
    if clicked then
        debug_print("[enemy] Enemy at ("..self.x..","..self.y..") clicked!")
        FLEE_SPEED = FLEE_SPEED + 0.02
    end
    return clicked
end

function enemy:trigger_death()
    self.state = "dying"
    self.anim_death:reset()
    self.death_timer = 0
end

function enemy:draw()
    if not self.visible or self.state == "gone" then return end
    -- Opacity logic: 1.0 inside smell_range, ramps down to 0.1 outside exponentially
    local alpha = 1.0
    if self.dist_to_dog and self.smell_range then
        if self.dist_to_dog > self.smell_range then
            local d = self.dist_to_dog - self.smell_range
            -- The farther from the edge, the lower the opacity (exponential falloff)
            local ramp = math.max(0, 1 - (d / (self.smell_range * 2))) -- fade over 2x smell_range
            alpha = 0.1 + 0.9 * (ramp^2.5)
        end
    end
    -- Death animation always at full opacity
    if self.state == "dying" then
        love.graphics.setColor(1,1,1,1)
        self.anim_death:draw(self.x - SPRITE_SIZE/2, self.y - SPRITE_SIZE/2, self.flip)
    elseif self.state == "dead_hold" then
        love.graphics.setColor(1,1,1,1)
        local frame = self.anim_death.base.frame_count
        self.anim_death.base:draw_frame(frame, self.x - SPRITE_SIZE/2, self.y - SPRITE_SIZE/2, self.flip)
    elseif self.state == "dead_fade" then
        local frame = self.anim_death.base.frame_count
        local alpha_fade = math.max(0, self.dead_fade_timer / 0.5)
        love.graphics.setColor(1,1,1,alpha_fade)
        self.anim_death.base:draw_frame(frame, self.x - SPRITE_SIZE/2, self.y - SPRITE_SIZE/2, self.flip)
    else
        love.graphics.setColor(1,1,1,alpha)
        if self.state == "idle" then
            self.anim_idle:draw(self.x - SPRITE_SIZE/2, self.y - SPRITE_SIZE/2, self.flip)
        elseif self.state == "walk_left" or self.state == "walk_right" then
            self.anim_walk:draw(self.x - SPRITE_SIZE/2, self.y - SPRITE_SIZE/2, self.flip)
        elseif self.state == "attack" then
            self.anim_attack:draw(self.x - SPRITE_SIZE/2, self.y - SPRITE_SIZE/2, self.flip)
        end
    end
    love.graphics.setColor(1,1,1,1)
end

return enemy
