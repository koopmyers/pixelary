class_name PlayerControl extends Control


static var names_colors: Dictionary[String, Color] = {}
static func get_name_color(p_name: String) -> Color:
	if names_colors.has(p_name):
		return names_colors[p_name]
	
	var rng := RandomNumberGenerator.new()
	rng.seed = p_name.hash()
	var color := Color.from_hsv(
		rng.randf_range(0.4, 0.9), 
		rng.randf_range(0.8, 0.9), 
		rng.randf_range(0.5, 0.7), 
		1.0
	)
	
	names_colors[p_name] = color
	
	return color


var player_name: String:
	set(x):
		player_name = x
		name_label.text = player_name
		name_label.add_theme_color_override(
			"font_color",
			get_name_color(player_name)
		)

var character_frames: SpriteFrames:
	set(x):
		character_frames = x
		character_sprite.sprite_frames = character_frames
		character_sprite.play("idle")

var is_drawing := false:
	set(x):
		is_drawing = x
		drawing_sprite.visible = is_drawing


@onready var name_label: Label = %NameLabel
@onready var character_sprite: AnimatedSprite2D = %CharacterAnimatedSprite2D
@onready var drawing_sprite: AnimatedSprite2D = %DrawingAnimatedSprite2D
@onready var message_control := %MessageControl


func _ready() -> void:
	drawing_sprite.hide()


@rpc("any_peer", "call_local", "reliable")
func pop_up_message(p_text: String):
	message_control.pop_up(p_text)
	character_sprite.play("talk")


func _on_message_control_visibility_changed() -> void:
	if not is_instance_valid(message_control):
		return
	
	if message_control.is_visible_in_tree():
		return
	
	character_sprite.play("idle")
