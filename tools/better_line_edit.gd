class_name BetterLineEdit extends LineEdit


const SUMIT_DURATION := 0.2 #sec


var normal_style_box: StyleBox
var hover_style_box: StyleBox
var editing_style_box: StyleBox
var sumit_style_box: StyleBox

var is_hovered := false

var _timer := Timer.new()

var button_normal_style_box: StyleBox
var button_font_color: Color
var button_hover_style_box: StyleBox
var button_font_hover_color: Color
var button_pressed_style_box: StyleBox
var button_font_pressed_color: Color
@export var button: Button


func _ready() -> void:
	normal_style_box = get_theme_stylebox("normal")
	hover_style_box = get_theme_stylebox("hover")
	editing_style_box = get_theme_stylebox("editing")
	sumit_style_box = get_theme_stylebox("sumit")
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	#focus_entered.connect(_on_focus_entered)
	#focus_exited.connect(_on_focus_exited)
	
	text_submitted.connect(_on_text_sumitted)
	_timer.timeout.connect(_on_text_sumitted_exited)
	_timer.one_shot = true
	_timer.wait_time = SUMIT_DURATION
	add_child(_timer)
	
	if button:
		button_normal_style_box = button.get_theme_stylebox("normal")
		button_font_color = button.get_theme_color("font_color")
		button_hover_style_box = button.get_theme_stylebox("hover")
		button_font_hover_color = button.get_theme_color("font_hover_color")
		button_pressed_style_box = button.get_theme_stylebox("pressed")
		button_font_pressed_color = button.get_theme_color("font_pressed_color")
		
		button.mouse_entered.connect(_on_mouse_entered)
		button.mouse_exited.connect(_on_mouse_exited)
		button.button_down.connect(_on_button_down)
		button.button_up.connect(_on_button_up)


func _on_mouse_entered():
	is_hovered = true
	
	if has_focus():
		_on_focus_entered()
		return
	
	add_theme_stylebox_override("normal", hover_style_box)
	
	if button:
		button.add_theme_stylebox_override(
			"normal",
			button_hover_style_box
		)
		button.add_theme_color_override(
			"font_color",
			button_font_hover_color
		)


func _on_mouse_exited():
	is_hovered = false
	
	if has_focus():
		_on_focus_entered()
		return
	
	add_theme_stylebox_override("normal", normal_style_box)
	if button:
		button.add_theme_stylebox_override(
			"normal",
			button_normal_style_box
		)
		button.add_theme_color_override(
			"font_color",
			button_font_color
		)


func _on_focus_entered():
	add_theme_stylebox_override("normal", editing_style_box)
	if button:
		button.add_theme_stylebox_override(
			"normal",
			button_hover_style_box
		)
		button.add_theme_color_override(
			"font_color",
			button_font_hover_color
		)


func _on_focus_exited():
	if is_hovered:
		_on_mouse_entered()
		return
	
	_on_mouse_exited()


func _on_text_sumitted(_text: String = ""):
	add_theme_stylebox_override("normal", sumit_style_box)
	_timer.start()
	
	if button:
		button.add_theme_stylebox_override(
			"normal",
			button_pressed_style_box
		)
		button.add_theme_color_override(
			"font_color",
			button_font_pressed_color
		)


func _on_text_sumitted_exited():
	_timer.stop()
	if is_hovered:
		_on_mouse_entered()
		return
	
	_on_mouse_exited()


func _on_button_down():
	_on_text_sumitted()
	_timer.stop()


func _on_button_up():
	_on_text_sumitted_exited()
