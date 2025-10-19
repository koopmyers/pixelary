class_name NotificationPanel extends Control


const CROSS_ICON: SpriteFrames = preload("uid://oayoqfhiv1to")
const CLIPBOARD_ICON: SpriteFrames = preload("uid://bqeuukt4q1ecy")

@export var normal_position: Vector2
@export var pop_up_position: Vector2
@export var pop_up_duration: float = 3.0


var _tween: Tween

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var label: Label = %Label


func _ready() -> void:
	position = normal_position
	hide()


func pop_up(icon: SpriteFrames, message: String):
	
	sprite.sprite_frames = icon
	sprite.play()
	label.text = message
	
	if _tween and _tween.is_valid():
		_tween.kill()
	
	_tween = create_tween()
	show()
	_tween.tween_property(
		self,
		"position",
		pop_up_position,
		0.3
	)
	_tween.tween_property(
		self,
		"position",
		normal_position,
		0.2
	).set_delay(pop_up_duration)
	_tween.tween_callback(hide)
