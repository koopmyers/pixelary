extends Button


var url: String

func _ready() -> void:
	url = get_url()


func _pressed() -> void:
	var clipboard := text
	if url:
		clipboard = url + "?room_id=" + text
	
	DisplayServer.clipboard_set(clipboard)


func get_url() -> String:
	if OS.get_name() != "Web":
		return ""
	
	return str(JavaScriptBridge.eval('''
		const currentUrl = new URL(window.location.href);
		currentUrl.origin + currentUrl.pathname;
	''', 
		true
	))
