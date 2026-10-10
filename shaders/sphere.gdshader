shader_type canvas_item;

// License: CC0
// Author: Ultipuk, https://ultipuk.xyz
// Link: https://godotshaders.com/shader/2d-sphere-projection-with-rotation

//#define USE_UNIFORM_TEXTURE

/** In UV coords. */
uniform vec2 center = vec2(0.5, 0.5);

/** In UV coords. */
uniform float radius: hint_range(0.0, 2.0) = 0.5;

group_uniforms rotation_speed;
/** In radians per second. */
uniform float rotation_speed_x = 0.0;
/** In radians per second. */
uniform float rotation_speed_y = 0.3;
/** In radians per second. */
uniform float rotation_speed_z = 0.0;

group_uniforms rotation_offset;
/** In radians. */
uniform float rotation_offset_x = 0.0;
/** In radians. */
uniform float rotation_offset_y = 0.0;
/** In radians. */
uniform float rotation_offset_z = 0.0;

#ifdef USE_UNIFORM_TEXTURE
/** Just a color texture. */
uniform sampler2D color_texture;
#endif


vec3 rotate_x(vec3 p, float a) {
	float s = sin(a);
	float c = cos(a);
	
	return vec3(
		p.x,
		c * p.y - s * p.z,
		s * p.y + c * p.z
	);
}

vec3 rotate_y(vec3 p, float a) {
	float s = sin(a);
	float c = cos(a);
	
	return vec3(
		c * p.x + s * p.z,
		p.y,
		-s * p.x + c * p.z
	);
}

vec3 rotate_z(vec3 p, float a) {
	float s = sin(a);
	float c = cos(a);
	
	return vec3(
		c * p.x - s * p.y,
		s * p.x + c * p.y,
		p.z
	);
}


void fragment() {
	vec2 p = (UV - center) / radius;
	float r2 = dot(p, p);
	
	if (r2 > 1.0) {
		discard;
	}
	
	// Sphere normal / position
	vec3 n = vec3(
		p.x,
		p.y,
		sqrt(1.0 - r2)
	);
	
	// Angles in radians
	float ax = (TIME * rotation_speed_x + rotation_offset_x) * PI;
	float ay = (TIME * rotation_speed_y + rotation_offset_y) * PI;
	float az = (TIME * rotation_speed_z + rotation_offset_z) * PI;
	
	// Apply rotations
	n = rotate_x(n, ax);
	n = rotate_y(n, ay);
	n = rotate_z(n, az);
	
	// Sphere UV mapping
	float u = atan(-n.z, n.x) / TAU + 0.5;
	float v = asin(clamp(n.y, -1.0, 1.0)) / PI + 0.5;

#ifdef USE_UNIFORM_TEXTURE
	COLOR = texture(color_texture, vec2(u, v));
#else
	COLOR = texture(TEXTURE, vec2(u, v));
#endif
}