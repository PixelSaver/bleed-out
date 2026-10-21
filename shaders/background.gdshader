shader_type canvas_item;

uniform float curvature : hint_range(0.0, 2.0) = 0.5;
uniform float radius : hint_range(0.0, 0.5) = 0.5;
uniform sampler2D sct : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec2 new_uv = vec2(SCREEN_UV.x - 0.5, SCREEN_UV.y - 0.5);
	float edge_distance = -curvature * sqrt(pow(radius, 2) - pow(new_uv.x, 2)) + 1.0;
	vec2 result = vec2(new_uv.x, new_uv.y / edge_distance);
	result = vec2(result.x + 0.5, result.y + 0.5);
	
	COLOR = texture(sct, result);
	
}
