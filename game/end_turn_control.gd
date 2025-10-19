extends PanelContainer


signal timeout


var step := 0


@onready var timer: Timer = %Timer

@onready var step_one_container: Control = %Step1Container
@onready var step_two_container: Control = %Step2Container

@onready var loose_label: Label = %LooseLabel
@onready var win_control: Control = %WinControl
@onready var winner_label: Label = %WinnerLabel
@onready var winner_sprite: AnimatedSprite2D = %WinnerAnimatedSprite2D
@onready var word_label: Label = %WordLabel
@onready var points_label: Label = %PointsLabel

@onready var next_turn_control: Control = %NextTurnControl
@onready var next_player_label: Label = %NextPlayerLabel
@onready var next_player_sprite: AnimatedSprite2D = %NextPlayerAnimatedSprite2D

@onready var end_game_control: Control = %EndGameControl
@onready var end_game_points_label: Label = %EndGamePointsLabel


func _ready() -> void:
	hide()


func pop_up(player_control: PlayerControl, word: String, points: int, next_player_control: PlayerControl, total_points: int):
	if null == player_control:
		loose_label.show()
		win_control.hide()
	
	else:
		loose_label.hide()
		win_control.show()
		winner_label.text = player_control.player_name
		winner_label.add_theme_color_override(
			"font_color",
			PlayerControl.get_name_color(
				player_control.player_name
			)
		)
		winner_sprite.sprite_frames = player_control.character_frames
		winner_sprite.play("idle")
	
	word_label.text = word
	points_label.text = str(points)
	
	if null == next_player_control:
		next_turn_control.hide()
		end_game_control.show()
		end_game_points_label.text = str(total_points)
	else:
		end_game_control.hide()
		next_turn_control.show()
		next_player_label.text = next_player_control.player_name
		next_player_label.add_theme_color_override(
			"font_color",
			PlayerControl.get_name_color(
				next_player_control.player_name
			)
		)
		next_player_sprite.sprite_frames = next_player_control.character_frames
		next_player_sprite.play("idle")
	
	show()
	step_one()


func step_one():
	step = 1
	timer.start()
	step_one_container.show()
	step_two_container.hide()


func step_two():
	step = 2
	timer.start()
	step_one_container.hide()
	step_two_container.show()


func _on_timer_timeout() -> void:
	match step:
		1:
			step_two()
		2:
			hide()
			timeout.emit()
