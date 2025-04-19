-- settings.lua: Centralized game settings and constants
-- =================== MAIN GAME SETTINGS ===================
local settings = {}

-- ========== GAMEPLAY ==========
-- --- Enemy settings ---
settings.NUM_ENEMIES = 10 -- Number of enemies to spawn
settings.ENEMIES_ALWAYS_VISIBLE = true -- Enemies always visible
settings.ENEMIES_IDLE_DURATION_MAX = 2.0 -- Max idle duration for enemies (seconds)
settings.ENEMY_WALK_DISTANCE = 100 -- How far enemies walk
settings.ENEMY_WALK_SPEED = 150 -- Enemy walk speed (px/sec)
settings.ENEMY_CAT_CHASE_SPEED = 60 -- Cat chase speed (px/sec)
settings.ENEMY_FLEE_DIFFICULTY = 0.5 -- Multiplier for flee speed
settings.ENEMY_FLEE_SPEED = settings.ENEMY_FLEE_DIFFICULTY * settings.ENEMY_WALK_SPEED -- Flee speed
settings.ENEMY_SPRITE_SIZE = 48 -- Sprite size (px)
settings.ENEMY_IDLE_FRAMES = 4
settings.ENEMY_ATTACK_FRAMES = 4
settings.ENEMY_DEATH_FRAMES = 4
settings.ENEMY_WALK_FRAMES = 4
settings.ENEMY_IDLE_FRAME_TIME = 0.2
settings.ENEMY_ATTACK_FRAME_TIME = 0.12
settings.ENEMY_WALK_FRAME_TIME = 0.075
settings.ENEMY_DEATH_FRAME_TIME = 0.10

-- --- Dog settings ---
settings.DOG_START_X = 400 -- Dog initial X position
settings.DOG_START_Y = 300 -- Dog initial Y position
settings.DOG_RADIUS = 22 -- Dog collision/appearance radius
settings.DOG_SPRITE_OFFSET = 24 -- Dog sprite offset (px)
settings.DOG_MIN_FLEE_RANGE = 100 -- Min flee range
settings.DOG_MAX_FLEE_RANGE = 200 -- Max flee range
settings.DOG_INIT_FLEE_RANGE = 200 -- Initial flee range
settings.DOG_INIT_SMELL_RANGE = 40 -- Initial smell range
settings.DOG_MAX_SMELL_RANGE = 200 -- Max smell range
settings.DOG_FLEE_RANGE_SHRINK_STEP = (settings.DOG_INIT_FLEE_RANGE-20)/(settings.NUM_ENEMIES-1) -- Flee shrink per kill
settings.DOG_SMELL_RANGE_GROW_STEP = (settings.DOG_MAX_SMELL_RANGE-settings.DOG_INIT_SMELL_RANGE)/(settings.NUM_ENEMIES-1) -- Smell grow per kill
settings.DOG_ATTACK_DURATION = 1 -- Attack duration (seconds)
settings.DOG_MOUSE_STATIONARY_THRESHOLD = 2 -- Mouse stationary threshold (px)
settings.DOG_COLORS = {
    idle = {0.3, 0.6, 1.0, 1},      -- Blue
    walking = {0.1, 0.8, 0.2, 1},   -- Green
    attacking = {0.8, 0.3, 0.1, 1},-- Orange/red
}
settings.DOG_SMELL_COLOR = {0.8, 0.6, 0.2, 0.08} -- Smell circle color

-- ========== UI & VISUALS ==========
-- --- Stats box ---
settings.UI_STATS_BOX_X = 80
settings.UI_STATS_BOX_Y = 80
settings.UI_STATS_BOX_W = 320
settings.UI_STATS_BOX_H = 98
settings.UI_STATS_TEXT_MARGIN = 5

-- --- Win screen animation ---
settings.WIN_TRANSITION_TIME = 1.0 -- Win transition (seconds)
settings.WIN_OVERLAY_COLOR = {0,0,0,0.7} -- Overlay color
settings.SCORE_FADE_COLOR = {1,1,1,1} -- Score fade color
settings.FINAL_SCORE_BG = {0.13, 0.36, 0.86, 0.97} -- Score BG color
settings.FINAL_SCORE_SHADOW = {0.05, 0.10, 0.23, 0.55} -- Score shadow
settings.FINAL_SCORE_PADDING = 44 -- Score padding
settings.FINAL_SCORE_FONT_SIZE = 62 -- Score font size
settings.FINAL_SCORE_NUMBER_SHADOW = {0.08,0.14,0.22,0.85}
settings.FINAL_SCORE_NUMBER_COLOR = {1,1,1,1}
settings.WIN_SCORE_TEXT_COLOR = {1,1,1,1}
settings.WIN_SCORE_TEXT_SHADOW = {0,0,0,0}
settings.KILL_TEXT = "Gotcha!" -- Kill notification text

-- ========== AUDIO ==========
-- --- Music volumes ---
settings.AUDIO_MASTER_MUSIC_VOLUME = 0.35
settings.AUDIO_BASS_VOLUME = 0.55
settings.AUDIO_DRUMS_VOLUME = 0.48
settings.AUDIO_GUITARS_VOLUME = 0.42
settings.AUDIO_MELODY_VOLUME = 0.35
settings.AUDIO_OTHER_VOLUME = 0.30
settings.AUDIO_WOODWINDS_VOLUME = 0.30
settings.AUDIO_SFX_MASTER_VOLUME = 0.4

-- --- SFX volumes ---
settings.SFX_BKG_VOLUME = 0.6
settings.SFX_DOG_HIT_VOLUME = 0.8
settings.SFX_CAT_DEAD_VOLUME = 0.7
settings.SFX_EVENTS_MASTER_VOLUME = 1.0

-- --- Audio file paths ---
settings.AUDIO_MUSIC_PATHS = {
    bass      = "src/music/1/bass.mp3",
    drums     = "src/music/1/drums.mp3",
    guitars   = "src/music/1/guitars.mp3",
    melody    = "src/music/1/melody.mp3",
    other     = "src/music/1/other.mp3",
    woodwinds = "src/music/1/woodwinds.mp3"
}
settings.AUDIO_SFX_BKG_PATHS = {
    "src/sfx/bkg/dog_growling1.mp3",
    "src/sfx/bkg/cats_purring1.mp3"
}
settings.AUDIO_SFX_CAT_DEAD_PATH = "src/sfx/cats/dead1.mp3"
settings.AUDIO_SFX_DOG_BARK_PATHS = {
    "src/sfx/dog/bark1.mp3",
    "src/sfx/dog/bark2.mp3",
    "src/sfx/dog/bark3.mp3",
    "src/sfx/dog/bark4.mp3",
    "src/sfx/dog/bark5.mp3",
    "src/sfx/dog/bark6.mp3"
}

-- ========== SCENERY ==========
settings.SCENERY_TILE_SIZE = 48 -- Grass tile size
settings.SCENERY_GRASS_COUNT = 6 -- Number of grass tile variations

-- ========== DEBUG ==========
settings.DEBUG_ENABLED = false -- Debug overlay toggle
settings.DEBUG_MAX_LINES = 32 -- Max debug lines

-- ========== FONT & SPRITES ==========
settings.FONT_MAIN = "src/fonts/Minecraft.ttf"
settings.SPRITE_DOG_IDLE = "src/sprites/dog_idle.png"
settings.SPRITE_DOG_WALK = "src/sprites/dog_walk.png"
settings.SPRITE_DOG_ATTACK = "src/sprites/dog_attack.png"
settings.SPRITE_ENEMY_IDLE = "src/sprites/enemy_idle.png"
settings.SPRITE_ENEMY_ATTACK = "src/sprites/enemy_attack.png"
settings.SPRITE_ENEMY_WALK = "src/sprites/enemy_walk.png"
settings.SPRITE_ENEMY_DEATH = "src/sprites/enemy_death.png"
settings.SPRITE_GRASS = {
    "src/sprites/grass/grass1.png",
    "src/sprites/grass/grass2.png",
    "src/sprites/grass/grass3.png",
    "src/sprites/grass/grass4.png",
    "src/sprites/grass/grass5.png",
    "src/sprites/grass/grass6.png"
}

return settings
