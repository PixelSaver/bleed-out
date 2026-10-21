shader_type canvas_item;

uniform float curvature : hint_range(0.0, 0.5) = 0.2;
uniform bool cylinder_x = true; // compress horizontally like a real cylinder

void fragment() {
    vec2 uv = UV;

    // -1 at the left edge, 0 in the middle, +1 at the right edge
    float x = (uv.x - 0.5) * 2.0;

    // 1 in the middle, 0 at the edges (circular profile)
    float depth = sqrt(max(1.0 - x * x, 0.0));

    // Sampling lower in the texture makes the content appear higher on screen
    uv.y += curvature * depth;
	if (uv.y > 1.0) {
		uv.y -= 1.0;
	}

    // Optional: wrap the texture around the cylinder horizontally
    if (cylinder_x) {
        uv.x = asin(clamp(x, -1.0, 1.0)) / PI + 0.5;
    }

    if (uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0); // transparent outside the texture
    } else {
        COLOR = texture(TEXTURE, uv);
    }
}