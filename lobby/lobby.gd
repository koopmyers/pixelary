extends Control

signal created
signal joined(session_id: String)


@export var character_collection: CharactersCollection
@export var player_names_pool: PixelaryWordsPool

@onready var default_player_name := player_names_pool.get_random_word()

@onready var character_selector := %CharactersSelector
@onready var name_line_edit: LineEdit = %NameLineEdit

@onready var join_line_edit: LineEdit = %JoinLineEdit


func get_player_character() -> SpriteFrames:
	return character_selector.character_frames


func get_player_character_id() -> int:
	return character_collection.get_id(
		character_selector.character_frames
	)


func get_player_name() -> String:
	var text := name_line_edit.text
	if "" == text:
		return default_player_name
	
	return text


func _on_create_button_pressed() -> void:
	created.emit()


func _on_join_line_edit_text_submitted(p_text: String) -> void:
	joined.emit(p_text)
	join_line_edit.text = ""


func _on_join_button_pressed() -> void:
	joined.emit(join_line_edit.text)
	join_line_edit.text = ""
