extends AnimatedSprite2D

#static signal reference_changed

static var reference: AnimatedSprite2D


@export var is_reference := false


func _ready() -> void:
	animation_changed.connect(_on_animation_changed)
	if is_reference:
		reference = self
	
	if is_instance_valid(reference):
		set_frame_and_progress(0, reference.frame_progress)


func _on_animation_changed():
	if is_instance_valid(reference):
		set_frame_and_progress(frame, reference.frame_progress)
