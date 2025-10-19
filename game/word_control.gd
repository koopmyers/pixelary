extends Control


signal timout


@export var words_pool: PixelaryWordsPool
@export var wait_time: float = 60.0

var word: StringName:
	set(x):
		show()
		word = x.to_lower()
		if is_secret:
			label.text = hide_word(word)
		else:
			label.text = word
		
		time_left = wait_time
		timer_running = true

var is_secret := false:
	set(x):
		is_secret = x
		if is_secret:
			label.text = hide_word(word)
		else:
			label.text = word


var time_left: float = 0.0
var timer_running := false

@onready var progress_bar := %ProgressBar
@onready var label := %Label


func _ready() -> void:
	hide()
	words_pool.randomize_pool()


func hide_word(p_word: StringName) -> StringName:
	var string: StringName = ""
	for c in String(p_word):
		if c != " ": # Space:
			string += "_"
		else:
			string += c
	
	return string


func clear():
	label.text = ""
	time_left = 0.0
	timer_running = false


func get_relative_time_left() -> float:
	return time_left/wait_time


func _process(delta: float) -> void:
	if timer_running:
		time_left -= delta
		if time_left <= 0.0:
			time_left = 0.0
			timer_running = false
			timout.emit()
	
	progress_bar.max_value = wait_time
	progress_bar.value = wait_time - time_left
