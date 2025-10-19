@tool
class_name PaintSurface extends TextureRect


@export var surface_size := Vector2i(64, 64):
	set(x):
		surface_size = x

@export var background_color := Color.WHITE

var surface_image: Image = Image.new()
var bitmap: PackedByteArray:
	set(x):
		surface_image.set_data(
			surface_image.get_width(),
			surface_image.get_height(),
			false,
			surface_image.get_format(),
			x
		)
	get:
		return surface_image.get_data()


func _ready() -> void:
	#create our surface image and display it
	surface_image = Image.create(surface_size.x, surface_size.y, false, Image.FORMAT_RGB8)
	surface_image.fill(background_color)
	texture = ImageTexture.create_from_image(surface_image)


func get_pixel(rect_position: Vector2) -> Vector2i:
	var relative_rect_position := rect_position/get_rect().size
	return Vector2i(relative_rect_position * Vector2(surface_size))


func get_pixel_size() -> Vector2i:
	var relative_pixel_size := Vector2.ONE/Vector2(surface_size)
	return Vector2i(relative_pixel_size * get_rect().size)


func get_pixel_position(pixel_position: Vector2) -> Vector2:
	var relative_pixel_position := pixel_position/Vector2(surface_size)
	return relative_pixel_position * get_rect().size


func get_pixel_global_position(pixel_position: Vector2) -> Vector2:
	return global_position + get_pixel_position(pixel_position)


func get_pixel_color(p_position: Vector2i) -> Color:
	return surface_image.get_pixel(
		p_position.x,
		p_position.y,
	)


@rpc("any_peer", "call_local", "reliable")
func paint(p_position: Vector2i, p_color: Color):
	surface_image.set_pixel(
		p_position.x,
		p_position.y,
		p_color
	)
	#surface_image.fill_rect(
		#Rect2(p_position, Vector2.ONE),
		#p_color
	#)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	#Update this surface here, instead of every paint call(better optimised
	texture.update(surface_image)
	#texture = ImageTexture.create_from_image(surface_image)
#	surface_texture.flags = 0


func clear():
	surface_image.fill(background_color)
