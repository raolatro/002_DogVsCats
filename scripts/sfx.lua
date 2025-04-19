-- SFX System for DogPoo Game
-- Handles background and event SFX with scalable, controllable volumes

local settings = require("scripts.settings")
local sfx = {}

-- Volume Controls
sfx.BKG_VOLUME = settings.SFX_BKG_VOLUME -- Main SFX background layer
sfx.DOG_HIT_VOLUME = settings.SFX_DOG_HIT_VOLUME -- Dog bark volume
sfx.CAT_DEAD_VOLUME = settings.SFX_CAT_DEAD_VOLUME -- Cat dead volume
sfx.EVENTS_MASTER_VOLUME = settings.SFX_EVENTS_MASTER_VOLUME -- Master volume for all event SFX

-- Background SFX (looping stems)
sfx.bkg_stems = {}
for _, path in ipairs(settings.AUDIO_SFX_BKG_PATHS) do
    table.insert(sfx.bkg_stems, love.audio.newSource(path, "static"))
end
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
sfx.cat_dead = love.audio.newSource(settings.AUDIO_SFX_CAT_DEAD_PATH, "static")
sfx.dog_barks = {}
for _, path in ipairs(settings.AUDIO_SFX_DOG_BARK_PATHS) do
    table.insert(sfx.dog_barks, love.audio.newSource(path, "static"))
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
