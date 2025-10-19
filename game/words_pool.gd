@tool
class_name PixelaryWordsPool extends Resource


@export_file() var source_file
@export_tool_button("Process from source file") var process_file_tool_button := process_source_file

@export var max_length := 12
@export var words: Array[StringName] = []

var used_words: Array[StringName] = []
var rng := RandomNumberGenerator.new()

func process_source_file():
	var file := FileAccess.open(source_file, FileAccess.READ)
	if not file:
		printerr("Cannot open file")
		return
	
	words.clear()
	while file.get_position() < file.get_length():
		var line = file.get_line().strip_edges()
		if line == "":
			continue
		
		if max_length < line.length():
			continue
		
		words.append(line)
	
	file.close()


func randomize_pool():
	rng.randomize()


func get_random_word() -> StringName:
	if words.is_empty():
		words += used_words
		used_words.clear()
	
	var rn := rng.randi() % len(words)
	var word := words[rn]
	words.remove_at(rn)
	used_words.append(word)
	return word
