@tool
extends Button


@export var color := Color.RED:
	set(x):
		color = x
		
		if is_instance_valid(color_indicator):
			color_indicator.modulate = color


@onready var color_indicator: Control = %ColorIndicator


func _ready() -> void:
	color = color
	if button_pressed:
		pressed.emit()
