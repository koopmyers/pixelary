extends Node


#signal pressed


@export var toggle_input_action: InputEvent
@export var window: Window
var debug_build_only := true


func _input(event: InputEvent) -> void:
	if debug_build_only and not OS.is_debug_build():
		return
	
	if not event.is_pressed():
		return
	
	if event.is_match(toggle_input_action):
		window.visible = not window.visible
		#pressed.emit()
