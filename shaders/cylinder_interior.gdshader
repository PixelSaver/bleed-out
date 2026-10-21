shader_type canvas_item;

uniform float curvature : hint_range(0.0, 2.0) = 0.5;
uniform float radius : hint_range(0.0, 0.5) = 0.5;
uniform float camera_y = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	float x = UV.x - 0.5;
	
	float edge_distance = 1.0 - curvature * sqrt(radius*radius - x*x);
	
	float uv_per_screen = dFdy(UV.y) / dFdy(SCREEN_UV.y);
	float screen_y = (SCREEN_UV.y - 0.5) * uv_per_screen;
	
	float result_y = UV.y + screen_y * (1.0 / edge_distance - 1.0);
	
	COLOR = texture(TEXTURE, vec2(UV.x, fract(result_y)));
	
	//vec2 new_uv = vec2(UV.x - 0.5, UV.y - 0.5);
	//float edge_distance = -curvature * sqrt(pow(radius, 2) - pow(new_uv.x, 2)) + 1.0;
	//vec2 result = vec2(new_uv.x, new_uv.y / edge_distance);
	//result = vec2(result.x + 0.5, mod(result.y + 0.5, 1.0));
	//
	//COLOR = texture(TEXTURE, result);
	
}