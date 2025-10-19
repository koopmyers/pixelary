class_name CharactersCollection extends Resource


@export var characters: Array[SpriteFrames] = []


var characters_dict: Dictionary[int, SpriteFrames] = {}


func get_character(id: int) -> SpriteFrames:
	if characters_dict.is_empty():
		for character in characters:
			characters_dict[get_id(character)] = character
	
	if not characters_dict.has(id):
		printerr("Character collection {characters} doesn't have id: {id}".format({
			"id": id,
			"characters": characters_dict
		}))
	
	return characters_dict.get(id)


func get_id(character: SpriteFrames) -> int:
	return character.resource_path.hash()
