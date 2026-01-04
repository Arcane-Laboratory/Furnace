extends Node2D
class_name FurnaceAnimation
## Animated furnace background overlay
## Displays looping animation from furnace-furnace-sheet.png


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# Create sprite frames from the furnace sprite sheet
	_create_furnace_animation()


func _create_furnace_animation() -> void:
	if not animated_sprite:
		return
	
	var sprite_sheet := load("res://assets/sprites/furnace-furnace-sheet.png") as Texture2D
	if not sprite_sheet:
		push_error("FurnaceAnimation: Failed to load furnace-furnace-sheet.png")
		return
	
	# Sprite sheet dimensions: 492x2820
	# Calculate frame height: 2820 / 30 = 94px per frame
	var frame_width := 492
	var frame_height := 94
	var frame_count := 30
	
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")
	
	# Create animation
	sprite_frames.add_animation("furnace_loop")
	sprite_frames.set_animation_speed("furnace_loop", 10.0)  # 10 FPS
	sprite_frames.set_animation_loop("furnace_loop", true)
	
	# Create AtlasTexture for each frame
	for i in range(frame_count):
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = sprite_sheet
		atlas_texture.region = Rect2(0, i * frame_height, frame_width, frame_height)
		
		sprite_frames.add_frame("furnace_loop", atlas_texture)
	
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play("furnace_loop")
