local anim = require("scripts.anim")
local enemy_anim = {}
enemy_anim.__index = enemy_anim

function enemy_anim.new(img_path, frame_count, frame_time)
    local image = love.graphics.newImage(img_path)
    local self = setmetatable({}, enemy_anim)
    self.base = anim.new(image, 48, 48, frame_count, frame_time)
    return self
end

function enemy_anim:update(dt)
    self.base:update(dt)
end

function enemy_anim:draw(x, y, flip)
    self.base:draw(x, y, flip)
end

function enemy_anim:reset()
    debug_print("[enemy_anim:reset] Resetting animation. Frame count: "..tostring(self.base.frame_count))
    self.base:reset()
end

function enemy_anim:reset()
    self.base:reset()
end

return enemy_anim
