extends Control


@export var PlayerControlScene: PackedScene


func add_player(p_peer_id: int, p_name: String, p_character: SpriteFrames) -> Control:
	
	var control
	if has_node(str(p_peer_id)):
		control = get_node(str(p_peer_id))
	else:
		control = PlayerControlScene.instantiate()
		control.name = str(p_peer_id)
		add_child(control)
	
	control.player_name = p_name
	control.character_frames = p_character
	return control


func get_player_control(p_peer_id: int) -> Control:
	if not has_node(str(p_peer_id)):
		return null
	
	return get_node(str(p_peer_id))


func remove_player(p_peer_id: int):
	if not has_node(str(p_peer_id)):
		return
	
	var control = get_node(str(p_peer_id))
	remove_child(control)
	control.queue_free()


func clear():
	for child in get_children():
		remove_child(child)
		child.queue_free()
