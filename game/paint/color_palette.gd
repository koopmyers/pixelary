extends Control


@export var paint_cursor: PaintCursor


func _ready() -> void:
	for child in get_children():
		if not child is Button:
			continue
		
		child.pressed.connect(_on_color_button_pressed.bind(child))



func _on_color_button_pressed(button):
	paint_cursor.color = button.color
