-- audio.lua: Background music and SFX control for Dog VS Cats
local audio = {}

-- Master and per-stem volumes (default: not too loud)
audio.MASTER_MUSIC_VOLUME = 0.35

-- Individual music stem volumes
audio.BASS_VOLUME      = 0.55

audio.DRUMS_VOLUME     = 0.48

audio.GUITARS_VOLUME   = 0.42

audio.MELODY_VOLUME    = 0.35

audio.OTHER_VOLUME     = 0.30

audio.WOODWINDS_VOLUME = 0.30

-- Sound Effects volumes (for later)
audio.SFX_MASTER_VOLUME = 0.4
-- Add more SFX volumes as needed, e.g.:
-- audio.SFX_POPUP_VOLUME = 0.5

-- Internal handles for sources
local music_sources = {}
local music_paths = {
    bass      = "src/music/1/bass.mp3",
    drums     = "src/music/1/drums.mp3",
    guitars   = "src/music/1/guitars.mp3",
    melody    = "src/music/1/melody.mp3",
    other     = "src/music/1/other.mp3",
    woodwinds = "src/music/1/woodwinds.mp3"
}
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
