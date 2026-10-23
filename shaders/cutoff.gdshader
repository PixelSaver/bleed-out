shader_type canvas_item;

uniform float cutoff : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D noise : repeat_enable;
uniform float amplitude : hint_range(0.0, 0.5) = 0.04;
uniform float freq = 0.1;
uniform float speed = .05;

void fragment() {
    vec2 uv = UV;

    vec2 noise_uv = uv.x * freq + vec2(TIME * speed, 0.0);
    float n = texture(noise, noise_uv).r;

    float dynamic_cutoff = cutoff + (n - 0.5) * amplitude;

    if (uv.y < dynamic_cutoff) {
        COLOR.a = 0.0;
    }
}