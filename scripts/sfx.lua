-- SFX System for DogPoo Game
-- Handles background and event SFX with scalable, controllable volumes

local sfx = {}

-- Volume Controls
sfx.BKG_VOLUME = 0.6 -- Main SFX background layer
sfx.DOG_HIT_VOLUME = 0.8 -- Dog bark volume
sfx.CAT_DEAD_VOLUME = 0.7 -- Cat dead volume
sfx.EVENTS_MASTER_VOLUME = 1.0 -- Master volume for all event SFX

-- Background SFX (looping stems)
sfx.bkg_stems = {
    love.audio.newSource("src/sfx/bkg/dog_growling1.mp3", "static"),
    love.audio.newSource("src/sfx/bkg/cats_purring1.mp3", "static"),
}
sfx.bkg_index = 1

function sfx.play_next_bkg()
    local src = sfx.bkg_stems[sfx.bkg_index]
    src:setVolume(sfx.BKG_VOLUME)
    src:setLooping(false)
    src:stop()
    src:play()
    sfx._bkg_playing = src
end

function sfx.update(dt)
    if sfx._bkg_playing and not sfx._bkg_playing:isPlaying() then
        sfx.bkg_index = (sfx.bkg_index % #sfx.bkg_stems) + 1
        sfx.play_next_bkg()
    end
end

function sfx.start_bkg()
    for _, src in ipairs(sfx.bkg_stems) do src:stop() end
    sfx.bkg_index = 1
    sfx.play_next_bkg()
end

function sfx.stop_bkg()
    for _, src in ipairs(sfx.bkg_stems) do src:stop() end
end

-- Event SFX
sfx.cat_dead = love.audio.newSource("src/sfx/cats/dead1.mp3", "static")
sfx.dog_barks = {}
for i=1,6 do
    sfx.dog_barks[i] = love.audio.newSource(string.format("src/sfx/dog/bark%d.mp3", i), "static")
end

function sfx.play_cat_dead()
    sfx.cat_dead:setVolume(sfx.CAT_DEAD_VOLUME * sfx.EVENTS_MASTER_VOLUME)
    sfx.cat_dead:stop() sfx.cat_dead:play()
end

function sfx.play_dog_bark()
    local idx = love.math.random(1, #sfx.dog_barks)
    local bark = sfx.dog_barks[idx]
    bark:setVolume(sfx.DOG_HIT_VOLUME * sfx.EVENTS_MASTER_VOLUME)
    bark:stop() bark:play()
end

return sfx
