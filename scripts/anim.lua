-- Simple animation handler for sprite sheets
local anim = {}
anim.__index = anim

function anim.new(image, frame_width, frame_height, frame_count, frame_time)
    local self = setmetatable({}, anim)
    self.image = image
    self.frame_width = frame_width
    self.frame_height = frame_height
    self.frame_count = frame_count
    self.frame_time = frame_time or 0.12
    self.time = 0
    self.current_frame = 1
    self.frames = {}
    for i = 0, frame_count - 1 do
        table.insert(self.frames, love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height, image:getDimensions()))
    end
    return self
end

function anim:update(dt)
    self.time = self.time + dt
    while self.time >= self.frame_time do
        self.time = self.time - self.frame_time
        self.current_frame = self.current_frame + 1
        if self.current_frame > self.frame_count then
            self.current_frame = 1
        end
    end
end

function anim:draw(x, y, flip)
    local frame = self.current_frame
    if frame < 1 or frame > self.frame_count or not self.frames[frame] then
        print("[anim] Warning: frame out of bounds! current_frame="..tostring(frame).." (should be 1-"..self.frame_count..")")
        frame = 1
    end
    if flip then
        love.graphics.draw(self.image, self.frames[frame], x + self.frame_width, y, 0, -1, 1)
    else
        love.graphics.draw(self.image, self.frames[frame], x, y)
    end
end

function anim:draw_frame(frame, x, y, flip)
    if frame < 1 or frame > self.frame_count or not self.frames[frame] then
        print("[anim] Warning: draw_frame out of bounds! frame="..tostring(frame).." (should be 1-"..self.frame_count..")")
        frame = 1
    end
    if flip then
        love.graphics.draw(self.image, self.frames[frame], x + self.frame_width, y, 0, -1, 1)
    else
        love.graphics.draw(self.image, self.frames[frame], x, y)
    end
end

function anim:reset()
    self.current_frame = 1
    self.time = 0
end

return anim
