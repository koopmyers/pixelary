@tool
extends Button


@export var character_frames: SpriteFrames:
	set(x):
		character_frames = x
		if is_instance_valid(animated_sprite):
			animated_sprite.sprite_frames = character_frames



@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	animated_sprite.sprite_frames = character_frames
	_toggled(button_pressed)


func _toggled(toggled_on: bool) -> void:
	if not is_instance_valid(animated_sprite):
		return
	
	if toggled_on:
		animated_sprite.play("idle")
	else:
		animated_sprite.pause()
