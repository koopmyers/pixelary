extends Control


@onready var label: Label = %Label
@onready var timer: Timer = %Timer


func _ready() -> void:
	hide()


func pop_up(p_text: String):
	label.text = p_text
	set_anchors_and_offsets_preset(
		Control.PRESET_BOTTOM_RIGHT
	)
	show()
	timer.start()


func _on_timer_timeout() -> void:
	hide()
