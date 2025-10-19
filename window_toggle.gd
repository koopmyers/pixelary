extends Window


func _ready() -> void:
	hide()
	#force_native = true


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		hide()


func toggle() -> void:
	visible = not visible
