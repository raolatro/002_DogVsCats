local anim = require("scripts.anim")
local dog = {}

dog.x = 400
dog.y = 300
dog.prev_x = 400
dog.prev_y = 300
dog.flee_range = 200 -- Controls cat fleeing/speed, starts large

dog.smell_range = 40 -- Controls opacity, starts small

NUM_ENEMIES = 5
dog.MIN_FLEE_RANGE = 100
DOG_FLEE_RANGE_SHRINK_STEP = (200-20)/(NUM_ENEMIES-1) -- Shrinks per kill

dog.MAX_SMELL_RANGE = 200
DOG_SMELL_RANGE_GROW_STEP = (200-40)/(NUM_ENEMIES-1) -- Grows per kill


dog.state = "idle" -- idle, walking, attacking
dog.potty_timer = 0

dog.radius = 22 -- radius of the animated dog dot

dog.animations = {}
dog.sprite_offset = 24 -- half of 48 (sprite is 48x48)
dog.facing_left = false -- true if last movement was to the left

dog.colors = {
    idle = {0.3, 0.6, 1.0, 1},      -- blue
    walking = {0.1, 0.8, 0.2, 1},   -- green
    attacking = {0.8, 0.3, 0.1, 1},  -- orange/red
}

dog.smell_color = {0.8, 0.6, 0.2, 0.08} -- more faded smell circle

dog.mouse_stationary_threshold = 2 -- pixels

dog.ATTACK_DURATION = 1 -- seconds

function dog:load()
    -- Load animations (4 frames, 48x48)
    local idle_img = love.graphics.newImage("src/sprites/dog_idle.png")
    local walk_img = love.graphics.newImage("src/sprites/dog_walk.png")
    local attack_img = love.graphics.newImage("src/sprites/dog_attack.png")
    self.animations.idle = anim.new(idle_img, 48, 48, 4, 0.18)
    self.animations.walking = anim.new(walk_img, 48, 48, 4, 0.13)
    self.animations.attacking = anim.new(attack_img, 48, 48, 4, 0.18)
end

function dog:update(mouse_x, mouse_y, dt)
    -- Smell range flash timer update
    if self.smell_flash_timer and self.smell_flash_timer > 0 then
        self.smell_flash_timer = self.smell_flash_timer - dt
        if self.smell_flash_timer < 0 then self.smell_flash_timer = 0 end
    end
    -- State transitions
    if self.state == "attacking" then
        self.potty_timer = self.potty_timer - dt
        if self.potty_timer <= 0 then
            -- Return to idle/walking
            if self:is_mouse_stationary(mouse_x, mouse_y) then
                self.state = "idle"
            else
                self.state = "walking"
            end
        end
    else
        if self:is_mouse_stationary(mouse_x, mouse_y) then
            self.state = "idle"
        else
            self.state = "walking"
        end
    end
    -- Track facing direction
    self.facing_left = (mouse_x < self.x)
    self.prev_x = self.x
    self.prev_y = self.y
    self.x = mouse_x
    self.y = mouse_y
    -- Update animation
    if self.state == "idle" or self.state == "walking" or self.state == "attacking" then
        self.animations[self.state]:update(dt)
    end
end

function dog:trigger_potty()
    self.state = "attacking"
    self.potty_timer = self.ATTACK_DURATION
end

function dog:increase_flee_range()
    self.flee_range = math.max(self.MIN_FLEE_RANGE, self.flee_range - DOG_FLEE_RANGE_SHRINK_STEP)
end

function dog:increase_smell_range()
    self.smell_range = math.min(self.MAX_SMELL_RANGE, self.smell_range + DOG_SMELL_RANGE_GROW_STEP)
    self:trigger_smell_flash()
end

function dog:trigger_smell_flash()
    self.smell_flash_duration = 1.0
    self.smell_flash_timer = self.smell_flash_duration
end

function dog:is_mouse_stationary(mx, my)
    return math.abs(mx - self.prev_x) < self.mouse_stationary_threshold and math.abs(my - self.prev_y) < self.mouse_stationary_threshold
end

function dog:draw()
    if self.visible == false then return end
    -- Smell range flash (white, 50% -> 0% opacity over 1s)
    if self.smell_flash_timer and self.smell_flash_timer > 0 then
        local alpha = 0.5 * (self.smell_flash_timer / self.smell_flash_duration)
        love.graphics.setColor(1,1,1,alpha)
        love.graphics.circle("line", self.x, self.y, self.smell_range)
        love.graphics.setColor(1,1,1,1)
    end
    -- Dog character: sprite for idle/walking/attacking (always 100% opacity, flip as needed)
    if self.state == "idle" or self.state == "walking" or self.state == "attacking" then
        love.graphics.setColor(1,1,1,1)
        local flip = self.facing_left
        self.animations[self.state]:draw(self.x - self.sprite_offset, self.y - self.sprite_offset, flip)
    else
        local color = self.colors[self.state] or {1,1,1,1}
        love.graphics.setColor(color)
        love.graphics.circle("fill", self.x, self.y, self.radius)
    end
end

function dog:reset()
    self.x = 400
    self.y = 300
    self.prev_x = 400
    self.prev_y = 300
    self.smell_range = 60
    self.state = "idle"
    self.potty_timer = 0
    self.facing_left = false
    self.visible = true
    for _, animobj in pairs(self.animations) do
        animobj:reset()
    end
end

return dog