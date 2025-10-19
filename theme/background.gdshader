shader_type canvas_item;

uniform float speed_factor = 1.0;
instance uniform vec4 black_color: source_color =  vec4(0.0, 0.0, 0.0, 1.0);
instance uniform vec4 white_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 new_uv = vec2(1.0, 1.0)*fract(TIME*speed_factor) + UV;
	COLOR = texture(TEXTURE, new_uv);
	
	if (COLOR == vec4(0.0, 0.0, 0.0, 1.0)) {
		COLOR = black_color;
	} else if (COLOR == vec4(1.0, 1.0, 1.0, 1.0)) {
		COLOR = white_color;
	}// black
	
}