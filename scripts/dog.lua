local settings = require("scripts.settings")
local anim = require("scripts.anim")
local dog = {}

dog.x = settings.DOG_START_X
dog.y = settings.DOG_START_Y
dog.prev_x = settings.DOG_START_X
dog.prev_y = settings.DOG_START_Y
dog.flee_range = settings.DOG_INIT_FLEE_RANGE -- Controls cat fleeing/speed, starts large
dog.smell_range = settings.DOG_INIT_SMELL_RANGE -- Controls opacity, starts small

dog.MIN_FLEE_RANGE = settings.DOG_MIN_FLEE_RANGE
dog.MAX_SMELL_RANGE = settings.DOG_MAX_SMELL_RANGE
dog.MAX_FLEE_RANGE = settings.DOG_MAX_FLEE_RANGE
dog.FLEE_RANGE_SHRINK_STEP = settings.DOG_FLEE_RANGE_SHRINK_STEP
dog.SMELL_RANGE_GROW_STEP = settings.DOG_SMELL_RANGE_GROW_STEP

dog.state = "idle" -- idle, walking, attacking
dog.potty_timer = 0

dog.radius = settings.DOG_RADIUS -- radius of the animated dog dot

dog.animations = {}
dog.sprite_offset = settings.DOG_SPRITE_OFFSET -- half of 48 (sprite is 48x48)
dog.facing_left = false -- true if last movement was to the left

dog.colors = settings.DOG_COLORS
dog.smell_color = settings.DOG_SMELL_COLOR -- more faded smell circle
dog.mouse_stationary_threshold = settings.DOG_MOUSE_STATIONARY_THRESHOLD -- pixels
dog.ATTACK_DURATION = settings.DOG_ATTACK_DURATION -- seconds

function dog:load()
    -- Load animations (4 frames, 48x48)
    local idle_img = love.graphics.newImage(settings.SPRITE_DOG_IDLE)
    local walk_img = love.graphics.newImage(settings.SPRITE_DOG_WALK)
    local attack_img = love.graphics.newImage(settings.SPRITE_DOG_ATTACK)
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
    -- Track facing direction based on mouse movement
    if mouse_x < self.prev_x then
        self.facing_left = true
    elseif mouse_x > self.prev_x then
        self.facing_left = false
    end
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
    self.flee_range = math.max(self.MIN_FLEE_RANGE, self.flee_range - settings.DOG_FLEE_RANGE_SHRINK_STEP)
end

function dog:increase_smell_range()
    self.smell_range = math.min(self.MAX_SMELL_RANGE, self.smell_range + settings.DOG_SMELL_RANGE_GROW_STEP)
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