extends Node
## Centralized music and SFX management


# Music track paths (to be configured when assets are added)
var gameplay_theme_path: String = "res://assets/audio/furnace-flames.wav"
var main_menu_theme_path: String = "res://assets/audio/last-ember.wav"
var victory_theme_path: String = ""  # To be added
var defeat_theme_path: String = ""  # To be added

# Audio players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Sound effect system
var sound_effects: Dictionary = {
	"rune-accelerate": "res://assets/audio/rune-accelerate.wav",
	"rune-generic": "res://assets/audio/rune-generic.wav",
	"rune-explosive": "res://assets/audio/rune-generic.wav",  # Uses generic rune sound
	"burn": "res://assets/audio/burn.wav",
	"fireball-spawn": "res://assets/audio/fireball-spawn.wav",
	"enemy-death": "res://assets/audio/enemy-death.wav",
	"furnace-death": "res://assets/audio/furnace-death.wav",
	"level-complete": "res://assets/audio/level-complete.wav",  # TODO: Add audio file
	"level-failed": "res://assets/audio/level-failed.wav",
	"click": "res://assets/audio/click.wav",
	"structure-sell": "res://assets/audio/structure-sell.wav",
	"structure-buy": "res://assets/audio/structure-buy.wav",
	"pickup-spark": "res://assets/audio/pickup-spark.wav",
	"invalid-action": "res://assets/audio/invalid-action.wav",
	"fireball-travel": "res://assets/audio/fireball-travel.wav"
}

# Sound effect volume multipliers (designer-tunable via config resource)
var sound_volumes: Dictionary = {}

# Sound effect config resource (loaded from project)
@export var sound_config: Resource = null

# Pool of AudioStreamPlayers for rapid succession sounds (prevents cutting off)
var sfx_pool: Array[AudioStreamPlayer] = []
var pool_size: int = 8  # Support up to 8 simultaneous sounds

# Fireball travel sound (looping) - dedicated player
var fireball_travel_player: AudioStreamPlayer = null

# Pitch modulation settings (to prevent repetitive sounds)
var pitch_modulation_range: float = 0.15  # ±15% pitch variation
var use_pitch_modulation: bool = true  # Can be disabled if needed

# Gameplay audio muting (for victory/defeat modals)
var gameplay_sounds_muted: bool = false

# Fade transition settings
var fade_duration: float = 1.0  # seconds for transitions
var initial_fade_duration: float = 0.1  # seconds for initial playback from silence
var tween: Tween
var pending_track_path: String = ""  # Track to play after fade out completes
var pending_fade_in: bool = true
var is_transition: bool = false  # Track if we're transitioning between tracks

# Current track path (stored because duplicated streams have empty resource_path)
var current_track_path: String = ""


func _ready() -> void:
	# Create audio players (music_player is created fresh for each track in _start_music)
	music_player = null  # Will be created when needed
	sfx_player = AudioStreamPlayer.new()
	
	add_child(sfx_player)
	
	# Create fireball travel player (for looping sound)
	fireball_travel_player = AudioStreamPlayer.new()
	add_child(fireball_travel_player)
	
	# Create SFX pool for rapid succession sounds
	for i in range(pool_size):
		var player := AudioStreamPlayer.new()
		sfx_pool.append(player)
		add_child(player)
	
	# Initialize sound volumes with defaults (1.0 for all)
	for effect_name in sound_effects.keys():
		sound_volumes[effect_name] = 1.0
	
	# Load sound config resource if it exists
	_load_sound_config()
	
	# Note: music_player.finished signal is connected in _start_music when player is created
	
	# Connect to game state changes
	if GameManager:
		GameManager.state_changed.connect(_on_game_state_changed)
	
	# Start music based on initial state (for title screen/main menu)
	if GameManager:
		_on_game_state_changed(GameManager.current_state)


## Play background music with optional fade in
func play_music(track_path: String, fade_in: bool = true) -> void:
	if track_path.is_empty():
		push_warning("AudioManager: Empty track path provided")
		return
	
	# If same track is already playing, don't restart
	if current_track_path == track_path and music_player and is_instance_valid(music_player) and music_player.playing:
		return
	
	# Load the audio stream
	var stream: AudioStream = load(track_path)
	if not stream:
		push_warning("AudioManager: Failed to load music track: %s" % track_path)
		return
	
	# If music is playing, fade out first, then play new track (crossfade)
	if music_player and is_instance_valid(music_player) and music_player.playing:
		is_transition = true
		pending_track_path = track_path
		pending_fade_in = fade_in
		_fade_out_music()
		return
	
	# No music playing - start with fade-in
	is_transition = false
	_start_music(stream, fade_in, track_path)


## Stop music with optional fade out
func stop_music(fade_out: bool = true) -> void:
	if not music_player or not is_instance_valid(music_player) or not music_player.playing:
		return
	
	# Clear any pending track and current track path when stopping
	pending_track_path = ""
	current_track_path = ""
	
	if fade_out:
		_fade_out_music()
	else:
		music_player.stop()


## Load sound effect config resource
func _load_sound_config() -> void:
	# Try to load config resource
	var config_path := "res://resources/sound_effect_config.tres"
	if ResourceLoader.exists(config_path):
		sound_config = load(config_path) as SoundEffectConfig
		if sound_config:
			# Update volumes from config
			for effect_name in sound_effects.keys():
				var volume: float = sound_config.get_volume(effect_name)
				if volume >= 0.0:  # Valid volume
					sound_volumes[effect_name] = volume
		else:
			push_warning("AudioManager: Sound config resource exists but is not a SoundEffectConfig")


## Play one-shot sound effect (legacy method - use play_sound_effect instead)
func play_sfx(sfx_path: String) -> void:
	if sfx_path.is_empty():
		push_warning("AudioManager: Empty SFX path provided")
		return
	
	var stream: AudioStream = load(sfx_path)
	if not stream:
		push_warning("AudioManager: Failed to load SFX: %s" % sfx_path)
		return
	
	sfx_player.stream = stream
	sfx_player.play()


## Play sound effect by name with volume control and pitch modulation
func play_sound_effect(effect_name: String) -> void:
	if not sound_effects.has(effect_name):
		push_warning("AudioManager: Unknown sound effect: %s" % effect_name)
		return
	
	# Skip gameplay sounds when muted (but allow UI/feedback sounds)
	if gameplay_sounds_muted and _is_gameplay_sound(effect_name):
		return
	
	var sfx_path: String = sound_effects[effect_name]
	if sfx_path.is_empty():
		push_warning("AudioManager: Empty SFX path for effect: %s" % effect_name)
		return
	
	# Load the audio stream
	var stream: AudioStream = load(sfx_path)
	if not stream:
		push_warning("AudioManager: Failed to load SFX: %s" % sfx_path)
		return
	
	# Get volume multiplier (default to 1.0 if not set)
	var volume_multiplier: float = sound_volumes.get(effect_name, 1.0)
	
	# Find an available player from the pool
	var player: AudioStreamPlayer = _get_available_sfx_player()
	if not player:
		# All players busy, use main sfx_player (may cut off previous sound)
		player = sfx_player
	
	# Set stream
	player.stream = stream
	
	# Apply volume multiplier
	var base_volume_db: float = 0.0  # Full volume
	var final_volume_db: float = base_volume_db + linear_to_db(volume_multiplier)
	player.volume_db = final_volume_db
	
	# Apply randomized pitch modulation to prevent repetitive sounds
	if use_pitch_modulation:
		var pitch_variation: float = randf_range(-pitch_modulation_range, pitch_modulation_range)
		player.pitch_scale = 1.0 + pitch_variation
	else:
		player.pitch_scale = 1.0
	
	# Play the sound
	player.play()


## Get an available SFX player from the pool
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_pool:
		if not player.playing:
			return player
	return null  # All players busy


## Set volume multiplier for a specific sound effect (designer-tunable)
func set_sound_volume(effect_name: String, volume_multiplier: float) -> void:
	if not sound_effects.has(effect_name):
		push_warning("AudioManager: Unknown sound effect: %s" % effect_name)
		return
	
	# Clamp volume to reasonable range (0.0 to 2.0)
	volume_multiplier = clamp(volume_multiplier, 0.0, 2.0)
	sound_volumes[effect_name] = volume_multiplier


## Get volume multiplier for a specific sound effect
func get_sound_volume(effect_name: String) -> float:
	return sound_volumes.get(effect_name, 1.0)


## Play UI click sound (convenience method)
func play_ui_click() -> void:
	play_sound_effect("click")


## Start fireball travel sound (looping)
func start_fireball_travel() -> void:
	if not fireball_travel_player:
		return
	
	# Don't start fireball travel sound when gameplay sounds are muted
	if gameplay_sounds_muted:
		return
	
	var sfx_path: String = sound_effects.get("fireball-travel", "")
	if sfx_path.is_empty():
		return
	
	var stream: AudioStream = load(sfx_path)
	if not stream:
		push_warning("AudioManager: Failed to load fireball-travel sound")
		return
	
	# Set looping
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	# Get volume multiplier
	var volume_multiplier: float = sound_volumes.get("fireball-travel", 1.0)
	var final_volume_db: float = linear_to_db(volume_multiplier)
	
	fireball_travel_player.stream = stream
	fireball_travel_player.volume_db = final_volume_db
	fireball_travel_player.play()


## Stop fireball travel sound
func stop_fireball_travel() -> void:
	if fireball_travel_player and fireball_travel_player.playing:
		fireball_travel_player.stop()


## Mute all gameplay sounds (for victory/defeat modals)
## This stops active gameplay sounds and prevents new ones from playing
## UI sounds (clicks) and victory/defeat sounds still play
func mute_gameplay_sounds() -> void:
	gameplay_sounds_muted = true
	# Stop the looping fireball travel sound immediately
	stop_fireball_travel()
	# Stop any currently playing sounds in the pool
	for player in sfx_pool:
		if player.playing:
			player.stop()


## Unmute gameplay sounds (called when starting a new level)
func unmute_gameplay_sounds() -> void:
	gameplay_sounds_muted = false


## Check if a sound effect is a gameplay sound (should be muted during modals)
## Returns false for UI sounds that should always play
func _is_gameplay_sound(effect_name: String) -> bool:
	# These sounds should play even when gameplay is muted (UI/feedback sounds)
	var always_allowed := [
		"click",
		"level-complete",
		"level-failed",
	]
	return effect_name not in always_allowed


## Play victory theme
func play_victory_music() -> void:
	if victory_theme_path.is_empty():
		# Fallback to gameplay theme if victory theme not set
		if not gameplay_theme_path.is_empty():
			play_music(gameplay_theme_path, true)
		else:
			push_warning("AudioManager: No victory theme configured")
		return
	
	play_music(victory_theme_path, true)


## Play defeat theme
func play_defeat_music() -> void:
	if defeat_theme_path.is_empty():
		# Fallback to gameplay theme if defeat theme not set
		if not gameplay_theme_path.is_empty():
			play_music(gameplay_theme_path, true)
		else:
			push_warning("AudioManager: No defeat theme configured")
		return
	
	play_music(defeat_theme_path, true)


## Handle automatic music switching based on game state
func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.TITLE, GameManager.GameState.MENU:
			# Play title theme (last-ember.wav) for title screen and main menu
			if not main_menu_theme_path.is_empty():
				play_music(main_menu_theme_path, true)
			# Unmute gameplay sounds when returning to menu (reset state)
			unmute_gameplay_sounds()
		
		GameManager.GameState.BUILD_PHASE:
			if not gameplay_theme_path.is_empty():
				play_music(gameplay_theme_path, true)
			# Unmute gameplay sounds when starting a new level/build phase
			unmute_gameplay_sounds()
		
		GameManager.GameState.ACTIVE_PHASE:
			if not gameplay_theme_path.is_empty():
				play_music(gameplay_theme_path, true)
		
		GameManager.GameState.PAUSED:
			# Keep current music playing (don't change on pause)
			pass
		
		GameManager.GameState.GAME_OVER:
			# Music will be set by game_over.gd based on win/lose
			pass


## Fade in music volume
func _fade_in_music() -> void:
	if tween:
		tween.kill()
	
	if not music_player or not is_instance_valid(music_player):
		return
	
	tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, fade_duration)


## Start playing music (internal helper)
func _start_music(stream: AudioStream, fade_in: bool, track_path: String = "") -> void:
	# Stop and remove old player if it exists
	if music_player and is_instance_valid(music_player):
		music_player.stop()
		if music_player.finished.is_connected(_on_music_finished):
			music_player.finished.disconnect(_on_music_finished)
		music_player.queue_free()
	
	# Create a fresh player for each track (avoids state issues with reused players)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)
	
	music_player.stream = stream
	
	# Store the original track path for looping detection
	if not track_path.is_empty():
		current_track_path = track_path
	
	# Set looping based on track type
	_set_stream_looping()
	
	if fade_in:
		# Set starting volume and prepare tween before playing
		music_player.volume_db = -40.0
		
		# Kill any existing tween first
		if tween:
			tween.kill()
		
		# Use shorter fade for initial playback, longer for transitions
		var fade_time: float = initial_fade_duration if not is_transition else fade_duration
		
		# Create tween before playing - it will start animating immediately
		tween = create_tween()
		tween.tween_property(music_player, "volume_db", 0.0, fade_time)
		
		# Now start playback
		music_player.play()
	else:
		# No fade-in - play at full volume
		music_player.volume_db = 0.0
		music_player.play()


## Fade out music volume
func _fade_out_music() -> void:
	if tween:
		tween.kill()
	
	if not music_player or not is_instance_valid(music_player):
		_on_fade_out_complete()
		return
	
	tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
	tween.tween_callback(_on_fade_out_complete)


## Called when fade out completes
func _on_fade_out_complete() -> void:
	if music_player and is_instance_valid(music_player):
		music_player.stop()
	
	# If there's a pending track, play it now (this is a transition)
	if not pending_track_path.is_empty():
		var stream: AudioStream = load(pending_track_path)
		var should_fade: bool = pending_fade_in
		var track_path: String = pending_track_path  # Store path before clearing
		pending_track_path = ""  # Clear before starting
		
		if stream:
			# NOTE: Not duplicating stream - was causing music to not play
			# For transitions, use fade-in (pass original track_path for looping detection)
			_start_music(stream, should_fade, track_path)
	else:
		# No pending track - music was just stopped, clear current track path
		current_track_path = ""


## Set looping on audio stream based on track path
## For WAV files, looping is handled manually via _on_music_finished()
func _set_stream_looping() -> void:
	if not music_player or not is_instance_valid(music_player):
		return
	
	var stream: AudioStream = music_player.stream
	if not stream:
		return
	
	# Gameplay and main menu themes should loop
	var should_loop: bool = (
		current_track_path == gameplay_theme_path or 
		current_track_path == main_menu_theme_path
	)
	
	# Set looping based on stream type
	# WAV files: looping handled manually via _on_music_finished() to avoid playback issues
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = should_loop
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = should_loop


## Handle music finished signal - restart looping tracks
## Uses current_track_path since duplicated streams have empty resource_path
func _on_music_finished() -> void:
	if not music_player or not is_instance_valid(music_player) or not music_player.stream:
		return
	
	# Only restart if this is a looping track (gameplay or main menu)
	# Use stored current_track_path since duplicated streams have empty resource_path
	if current_track_path == gameplay_theme_path or current_track_path == main_menu_theme_path:
		# Restart the track (it will loop automatically if stream looping is set)
		music_player.play()
