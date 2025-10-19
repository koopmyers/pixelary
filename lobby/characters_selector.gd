extends Control


var character_frames: SpriteFrames


func _ready() -> void:
	character_frames = get_children().pop_front().character_frames # security
	
	for child in get_children():
		child.pressed.connect(
			_on_button_pressed.bind(child.character_frames)
		)
		if child.button_pressed:
			character_frames = child.character_frames


func _on_button_pressed(frames: SpriteFrames):
	character_frames = frames
