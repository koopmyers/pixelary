class_name PaintCursor extends Node2D


@export var paint_surface: PaintSurface
@export var color := Color.BLACK


func _ready() -> void:
	paint_surface.mouse_entered.connect(
		_on_paint_surface_mouse_entered
	)
	paint_surface.mouse_exited.connect(
		_on_paint_surface_mouse_exited
	)


var drawing_cursor := false
#var painting := false
#var last_painting_position: Vector2


func _on_paint_surface_mouse_entered():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	drawing_cursor = true
	queue_redraw()


func _on_paint_surface_mouse_exited():
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	drawing_cursor = false
	queue_redraw()

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#painting = event.is_pressed()
	#
	#
	#var surface_local_event := paint_surface.make_input_local(event)
	#var surface_rect := paint_surface.get_rect()
	#surface_rect.position = Vector2.ZERO
	#if not surface_rect.has_point(surface_local_event.position):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#return
	#
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#if not painting:
		#return
	#
	#var surface_position := paint_surface.get_surface_position(surface_local_event.position)
	#paint_surface.paint(surface_position, color)


func _process(_delta: float) -> void:
	if not is_visible_in_tree():
		return
	
	if not paint_surface.is_visible_in_tree():
		return
	
	global_position = get_global_mouse_position()
	var mouse_position := paint_surface.get_local_mouse_position()
	var surface_rect := paint_surface.get_rect()
	surface_rect.position = Vector2.ZERO
	if not surface_rect.has_point(mouse_position):
		return
	
	queue_redraw()
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	
	var pixel := paint_surface.get_pixel(mouse_position)
	if paint_surface.get_pixel_color(pixel) == color: 
		# to limit rpc call
		return
	
	paint_surface.paint.rpc(pixel, color)


func _draw() -> void:
	if not drawing_cursor:
		return
	
	var mouse_position := paint_surface.get_local_mouse_position()
	var pixel_global_position :=  paint_surface.get_pixel_global_position(
		paint_surface.get_pixel(mouse_position)
	)
	
	var offset := pixel_global_position - global_position
	
	var rect_size := paint_surface.get_pixel_size()
	var rect := Rect2(offset, rect_size)
	draw_rect(rect, color, false, 1.0)
	
	#draw_circle(Vector2.ZERO, rect_size.x*0.2, color, true)
