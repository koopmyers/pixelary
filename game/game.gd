extends Control

signal nofitication_emited(icon: SpriteFrames, message: String)


const TURN_POINTS: int = 100
const MAX_ROUNDS: int = 3

@export var characters_collection: CharactersCollection

var self_player_control


var turn_index := 0: # updated only on server
	set(x):
		if 0 == players_amount:
			turn_index = x
			return
		
		turn_index = posmod(x, players_amount)
		if players_amount <= turn_index:
			return
		
		current_drawing_player_peer_id = int(
			player_controls.get_child(
				turn_index
			).name
		)
		next_player_peer_id = int(
			player_controls.get_child(
				(turn_index + 1)%players_amount
		).name)

var current_drawing_player_peer_id: int = 0
var next_player_peer_id: int = 0

var players_amount: int:
	get:
		return len(player_controls.get_children())

var points := 0:
	set(x):
		points = x
		points_label.text = str(points)

var rounds := 1:
	set(x):
		rounds = x
		round_label.text = str(rounds)


@onready var session_button: Button = %SessionIdButton

@onready var points_label: Label = %PointsLabel
@onready var round_label: Label = %RoundLabel
@onready var paint_surface := %PaintSurface
@onready var player_controls := %PlayersContainer

@onready var start_button: Button = %StartButton
@onready var waiting_to_start_label: Label = %WaitingToStartLabel
@onready var word_control := %WordControl

@onready var entry_line_edit: LineEdit = %EntryLineEdit

@onready var end_turn_control := %EndTurnControl


func _ready() -> void:
	clear()


func reset() -> void:
	points = 0
	rounds = 1
	turn_index = 0
	
	word_control.hide()
	start_button.visible = multiplayer.is_server()
	waiting_to_start_label.visible = not start_button.visible


func clear() -> void:
	points = 0
	rounds = 1
	turn_index = 0
	current_drawing_player_peer_id = 0
	next_player_peer_id = 0
	
	start_button.hide()
	waiting_to_start_label.hide()
	word_control.hide()
	player_controls.clear()


func set_session_id(id: String):
	session_button.text = id


func add_self_player(p_peer_id: int, p_name: String, p_character: SpriteFrames):
	self_player_control = player_controls.add_player(
		p_peer_id,
		p_name,
		p_character,
	)
	
	self_player_control.is_drawing = p_peer_id == current_drawing_player_peer_id
	word_control.is_secret = not self_player_control.is_drawing
	
	start_button.visible = multiplayer.is_server()
	waiting_to_start_label.visible = not start_button.visible


@rpc("any_peer", "call_remote", "reliable")
func add_player(p_name: String, p_character_id: int):
	var peer_id := multiplayer.get_remote_sender_id()
	var control = player_controls.add_player(
		multiplayer.get_remote_sender_id(),
		p_name,
		characters_collection.get_character(p_character_id),
	)
	
	control.is_drawing = peer_id == current_drawing_player_peer_id


func remove_player(p_peer_id: int):
	player_controls.remove_player(p_peer_id)
	if not multiplayer.is_server():
		return
	
	if p_peer_id == current_drawing_player_peer_id:
		turn_index -= 1
		update_drawing_player_peer_id.rpc(
			current_drawing_player_peer_id,
			next_player_peer_id
		)


func is_last_turn() -> bool:
	return turn_index == players_amount-1


func is_last_round() -> bool:
	return rounds == MAX_ROUNDS


func _on_start_button_pressed() -> void:
	turn_index = 0
	start_button.hide()
	start_turn.rpc(
		rounds,
		current_drawing_player_peer_id,
		next_player_peer_id,
		word_control.words_pool.get_random_word()
	)


@rpc("authority", "call_local", "reliable")
func start_turn(p_round: int, p_drawing_player_peer_id: int, p_next_player_peer_id, p_word: StringName):
	paint_surface.clear()
	waiting_to_start_label.hide()
	rounds = p_round
	
	current_drawing_player_peer_id = p_drawing_player_peer_id
	next_player_peer_id = p_next_player_peer_id
	
	var control = player_controls.get_player_control(p_drawing_player_peer_id)
	if null != control:
		control.is_drawing = true
	
	word_control.word = p_word
	word_control.is_secret = true
	if null != self_player_control:
		word_control.is_secret = not self_player_control.is_drawing


@rpc("authority", "call_remote", "reliable")
func update_drawing_player_peer_id(p_current_peer_id: int, p_next_peer_id: int): # when player count change
	current_drawing_player_peer_id = p_current_peer_id
	next_player_peer_id = p_next_peer_id


@rpc("authority", "call_remote", "reliable")
func unpdate_word_time(p_time: float):
	word_control.time_left = p_time


@rpc("authority", "call_remote", "reliable")
func update_paint_surface(p_bitmap: PackedByteArray):
	paint_surface.bitmap = p_bitmap


func _on_word_control_timout() -> void:
	if not multiplayer.is_server():
		return
	
	lose_turn.rpc()


@rpc("any_peer", "call_local", "reliable")
func win_turn(p_points: int):
	var sender_id := multiplayer.get_remote_sender_id()
	points += p_points
	
	end_turn_control.pop_up(
		player_controls.get_player_control(sender_id),
		word_control.word,
		p_points,
		player_controls.get_player_control(next_player_peer_id),
		points
	)
	
	paint_surface.clear()
	word_control.clear()
	for control in player_controls.get_children():
		control.is_drawing = false


@rpc("authority", "call_local", "reliable")
func lose_turn():
	end_turn_control.pop_up(
		null,
		word_control.word,
		0,
		player_controls.get_player_control(next_player_peer_id),
		points
	)
	
	paint_surface.clear()
	word_control.clear()
	for control in player_controls.get_children():
		control.is_drawing = false


func _on_end_turn_control_timeout() -> void:
	if not multiplayer.is_server():
		return
	
	if is_last_turn():
		if is_last_round():
			end_game.rpc()
			return
		
		rounds += 1
	
	turn_index += 1
	
	var next_peer_id := next_player_peer_id
	if is_last_round():
		if is_last_turn():
			next_peer_id = -1
	
	start_turn.rpc(
		rounds,
		current_drawing_player_peer_id,
		next_peer_id,
		word_control.words_pool.get_random_word()
	)
	

@rpc("authority", "call_local", "reliable")
func end_game():
	reset()


func sumit_guess(p_guess: String):
	entry_line_edit.text = ""
	if "" == p_guess:
		return
	
	if "" != word_control.word:
		if word_control.word == p_guess.to_lower():
			if self_player_control.is_drawing:
				self_player_control.pop_up_message.rpc(
					word_control.hide_word(p_guess)
				)
			
			else:
				win_turn.rpc(
					int(TURN_POINTS * word_control.get_relative_time_left())
				)
			
			return
	
	self_player_control.pop_up_message.rpc(p_guess)



func _on_entry_line_edit_text_submitted(p_text: String) -> void:
	sumit_guess(p_text)
	#entry_line_edit.grab_click_focus()


func _on_entry_button_pressed() -> void:
	sumit_guess(entry_line_edit.text)


func _on_session_id_button_pressed() -> void:
	var notification_text := "Room ID copied to clipboard"
	if session_button.url:
		notification_text = "Room URL copied to clipboard"
	
	nofitication_emited.emit(
		NotificationPanel.CLIPBOARD_ICON,
		notification_text
	)
