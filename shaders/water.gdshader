shader_type canvas_item;

uniform float wave_frequency = 10.0;
uniform float wave_speed = 4.0;
uniform float wave_amplitude = 0.005;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	float wave_x = sin(UV.x * wave_frequency + TIME * wave_speed) * wave_amplitude - wave_amplitude;
	float wave_y = cos(UV.y * wave_frequency + TIME * wave_speed) * wave_amplitude - wave_amplitude;
	
	vec2 final_uv = UV + vec2(wave_x, wave_y);
	
	COLOR = texture(TEXTURE, final_uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
