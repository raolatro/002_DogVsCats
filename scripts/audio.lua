-- audio.lua: Background music and SFX control for Dog VS Cats
local settings = require("scripts.settings")
local audio = {}

-- Master and per-stem volumes from settings
audio.MASTER_MUSIC_VOLUME = settings.AUDIO_MASTER_MUSIC_VOLUME

audio.BASS_VOLUME      = settings.AUDIO_BASS_VOLUME

audio.DRUMS_VOLUME     = settings.AUDIO_DRUMS_VOLUME

audio.GUITARS_VOLUME   = settings.AUDIO_GUITARS_VOLUME

audio.MELODY_VOLUME    = settings.AUDIO_MELODY_VOLUME

audio.OTHER_VOLUME     = settings.AUDIO_OTHER_VOLUME

audio.WOODWINDS_VOLUME = settings.AUDIO_WOODWINDS_VOLUME

audio.SFX_MASTER_VOLUME = settings.AUDIO_SFX_MASTER_VOLUME

-- Internal handles for sources
local music_sources = {}
local music_paths = settings.AUDIO_MUSIC_PATHS
local music_volumes = {
    bass      = function() return audio.BASS_VOLUME end,
    drums     = function() return audio.DRUMS_VOLUME end,
    guitars   = function() return audio.GUITARS_VOLUME end,
    melody    = function() return audio.MELODY_VOLUME end,
    other     = function() return audio.OTHER_VOLUME end,
    woodwinds = function() return audio.WOODWINDS_VOLUME end
}

-- Call once in love.load()
function audio.init()
    for stem, path in pairs(music_paths) do
        local src = love.audio.newSource(path, "stream")
        src:setLooping(true)
        src:setVolume(audio.MASTER_MUSIC_VOLUME * music_volumes[stem]())
        src:play()
        music_sources[stem] = src
    end
end

-- Call in love.update() to keep per-stem volumes in sync if changed at runtime
function audio.update()
    for stem, src in pairs(music_sources) do
        src:setVolume(audio.MASTER_MUSIC_VOLUME * music_volumes[stem]())
    end
end

-- (Optional) Call this if you want to stop all music
function audio.stop_all()
    for _, src in pairs(music_sources) do
        src:stop()
    end
end

-- (Optional) SFX play stub for later
function audio.play_sfx(name)
    -- Implement SFX logic here later
end

return audio
