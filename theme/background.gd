extends TextureRect


@export var transition_duration := 0.3

@export var lobby_black_color: Color
@export var lobby_white_color: Color

@export var connection_black_color: Color
@export var connection_white_color: Color

@export var game_black_color: Color
@export var game_white_color: Color


var _tween: Tween


func reset_tween():
	if _tween and _tween.is_valid():
		_tween.kill()


func transit_to_lobby():
	reset_tween()
	_tween = create_tween().set_parallel()
	_tween.tween_method(
		_tween_black_color,
		get_instance_shader_parameter("black_color"),
		lobby_black_color,
		transition_duration
	)
	_tween.tween_method(
		_tween_white_color,
		get_instance_shader_parameter("white_color"),
		lobby_white_color,
		transition_duration
	)


func transit_to_connection_screen():
	reset_tween()
	_tween = create_tween().set_parallel()
	_tween.tween_method(
		_tween_black_color,
		get_instance_shader_parameter("black_color"),
		connection_black_color,
		transition_duration
	)
	_tween.tween_method(
		_tween_white_color,
		get_instance_shader_parameter("white_color"),
		connection_white_color,
		transition_duration
	)


func transit_to_game():
	reset_tween()
	_tween = create_tween().set_parallel()
	_tween.tween_method(
		_tween_black_color,
		get_instance_shader_parameter("black_color"),
		game_black_color,
		transition_duration
	)
	_tween.tween_method(
		_tween_white_color,
		get_instance_shader_parameter("white_color"),
		game_white_color,
		transition_duration
	)


func _tween_black_color(color: Color):
	set_instance_shader_parameter("black_color", color)


func _tween_white_color(color: Color):
	set_instance_shader_parameter("white_color", color)
