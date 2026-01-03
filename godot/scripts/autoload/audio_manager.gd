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

# Fade transition settings
var fade_duration: float = 1.0  # seconds for transitions
var initial_fade_duration: float = 0.1  # seconds for initial playback from silence
var tween: Tween
var pending_track_path: String = ""  # Track to play after fade out completes
var pending_fade_in: bool = true
var is_transition: bool = false  # Track if we're transitioning between tracks


func _ready() -> void:
	# Create audio players
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	
	add_child(music_player)
	add_child(sfx_player)
	
	# Connect to finished signal for looping
	music_player.finished.connect(_on_music_finished)
	
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
	if music_player.stream and music_player.stream.resource_path == track_path:
		if music_player.playing:
			return
	
	# Load the audio stream
	var stream: AudioStream = load(track_path)
	if not stream:
		push_warning("AudioManager: Failed to load music track: %s" % track_path)
		return
	
	# Duplicate stream to avoid modifying shared resources
	stream = stream.duplicate()
	
	# If music is playing, fade out first, then play new track (crossfade)
	if music_player.playing:
		is_transition = true
		pending_track_path = track_path
		pending_fade_in = fade_in
		_fade_out_music()
		return
	
	# No music playing - start with fade-in
	is_transition = false
	_start_music(stream, fade_in)


## Stop music with optional fade out
func stop_music(fade_out: bool = true) -> void:
	if not music_player.playing:
		return
	
	# Clear any pending track when stopping
	pending_track_path = ""
	
	if fade_out:
		_fade_out_music()
	else:
		music_player.stop()


## Play one-shot sound effect
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
		
		GameManager.GameState.BUILD_PHASE, GameManager.GameState.ACTIVE_PHASE:
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
	
	tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, fade_duration)


## Start playing music (internal helper)
func _start_music(stream: AudioStream, fade_in: bool) -> void:
	music_player.stream = stream
	
	# Set looping based on track type
	_set_stream_looping(stream)
	
	if fade_in:
		# Set starting volume and prepare tween before playing
		# This ensures the fade-in starts immediately when playback begins
		music_player.volume_db = -40.0
		
		# Kill any existing tween first
		if tween:
			tween.kill()
		
		# Use shorter fade for initial playback, longer for transitions
		var fade_time: float = initial_fade_duration if not is_transition else fade_duration
		
		# Create tween before playing - it will start animating immediately
		tween = create_tween()
		tween.tween_property(music_player, "volume_db", 0.0, fade_time)
		
		# Now start playback - the tween is already set up and will animate immediately
		music_player.play()
	else:
		# No fade-in - play at full volume
		music_player.volume_db = 0.0
		music_player.play()


## Fade out music volume
func _fade_out_music() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
	tween.tween_callback(_on_fade_out_complete)


## Called when fade out completes
func _on_fade_out_complete() -> void:
	music_player.stop()
	
	# If there's a pending track, play it now (this is a transition)
	if not pending_track_path.is_empty():
		var stream: AudioStream = load(pending_track_path)
		var should_fade: bool = pending_fade_in
		var track_path: String = pending_track_path
		pending_track_path = ""  # Clear before starting
		
		if stream:
			# Duplicate stream to avoid modifying shared resources
			stream = stream.duplicate()
			# For transitions, use fade-in
			_start_music(stream, should_fade)


## Set looping on audio stream based on track path
func _set_stream_looping(stream: AudioStream) -> void:
	if not stream:
		return
	
	var stream_path: String = stream.resource_path
	
	# Gameplay and main menu themes should loop
	var should_loop: bool = (
		stream_path == gameplay_theme_path or 
		stream_path == main_menu_theme_path
	)
	
	# Set looping based on stream type
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = should_loop
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = should_loop
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD if should_loop else AudioStreamWAV.LOOP_DISABLED


## Handle music finished signal - restart looping tracks
func _on_music_finished() -> void:
	if not music_player.stream:
		return
	
	var stream_path: String = music_player.stream.resource_path
	
	# Only restart if this is a looping track (gameplay or main menu)
	if stream_path == gameplay_theme_path or stream_path == main_menu_theme_path:
		# Restart the track (it will loop automatically if stream looping is set)
		music_player.play()
