extends Node

const MAX_PLAYERS_AMOUNT := 4

var player_connected_amount := 1

@onready var client := %TubeClient

@onready var background := %Background
@onready var lobby := %Lobby
@onready var connection_screen := %ConnectionScreen
@onready var game := %Game
@onready var notification_control := %Notification


func _ready() -> void:
	go_to_lobby()
	var url_session_id := get_session_id_from_url()
	if url_session_id:
		_on_lobby_joined(url_session_id)


func get_session_id_from_url() -> String:
	if OS.get_name() != "Web":
		return ""
	
	# Listen for incoming messages from JavaScript
	return str(JavaScriptBridge.eval('''
		let params = new URL(document.location).searchParams;
		let sessionID = params.get("room_id");
		if (sessionID) {
			decodeURIComponent(sessionID);
		} else {
			"";
		}
	''', 
		true
	))


func go_to_lobby():
	background.transit_to_lobby()
	lobby.show()
	connection_screen.hide()
	game.hide()
	game.clear()


func go_to_connection_screen():
	background.transit_to_connection_screen()
	lobby.hide()
	connection_screen.show()
	game.hide()


func go_to_game():
	background.transit_to_game()
	lobby.hide()
	connection_screen.hide()
	game.show()
	game.set_session_id(client.session_id)


func _on_lobby_created() -> void:
	go_to_connection_screen()
	client.create_session()


func _on_lobby_joined(session_id: String) -> void:
	if not client.context.is_session_id_valid(session_id):
		notification_control.pop_up(
			NotificationPanel.CROSS_ICON,
			"Room ID invalid"
		)
		return
	
	go_to_connection_screen()
	client.join_session(session_id)


func _on_tube_client_error_raised(code: TubeClient.SessionError, _message: String) -> void:
	match code:
		TubeClient.SessionError.CREATE_SESSION_FAILED:
			go_to_lobby()
			notification_control.pop_up(
				NotificationPanel.CROSS_ICON,
				"Cannot created room"
			)
		
		TubeClient.SessionError.JOIN_SESSION_FAILED:
			go_to_lobby()
			notification_control.pop_up(
				NotificationPanel.CROSS_ICON,
				"Cannot join room"
			)


func _on_tube_client_session_created() -> void:
	go_to_game()
	game.add_self_player(
		client.peer_id,
		lobby.get_player_name(),
		lobby.get_player_character()
	)


func _on_tube_client_session_joined() -> void:
	go_to_game()
	game.add_self_player(
		client.peer_id,
		lobby.get_player_name(),
		lobby.get_player_character()
	)

func _on_tube_client_session_left() -> void:
	go_to_lobby()
	notification_control.pop_up(
		NotificationPanel.CROSS_ICON,
		"Room connection lost"
	)

func _on_tube_client_peer_connected(peer_id: int) -> void:
	game.add_player.rpc_id(
		peer_id,
		lobby.get_player_name(),
		lobby.get_player_character_id(),
	)
	player_connected_amount += 1
	if client.is_server:
		send_game_state(peer_id)
		client.refuse_new_connections = MAX_PLAYERS_AMOUNT <= player_connected_amount


func _on_tube_client_peer_disconnected(peer_id: int) -> void:
	game.remove_player(peer_id)
	player_connected_amount -= 1
	if client.is_server:
		client.refuse_new_connections = MAX_PLAYERS_AMOUNT <= player_connected_amount


func _on_tube_client_peer_unstabilized(_peer_id: int) -> void:
	pass


func _on_tube_client_peer_stabilized(peer_id: int) -> void:
	pass 
	#if client.is_server:
		#send_game_state(peer_id)


func send_game_state(peer_id: int) -> void:
	game.update_paint_surface.rpc_id(
		peer_id,
		game.paint_surface.bitmap,
	)
	
	if not game.start_button.visible:
		game.start_turn.rpc_id(
			peer_id,
			game.rounds,
			game.current_drawing_player_peer_id,
			game.next_player_peer_id,
			game.word_control.word,
		)
		game.unpdate_word_time.rpc_id(
			peer_id,
			game.word_control.time_left,
		)
