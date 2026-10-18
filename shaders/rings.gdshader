shader_type canvas_item;

uniform int half_mode : hint_range(0, 2) = 0;

uniform vec4 gold_color : source_color = vec4(0.83, 0.61, 0.22, 1.0);
uniform vec4 eye_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 pupil_color : source_color = vec4(0.01, 0.01, 0.01, 1.0);
uniform float background_alpha : hint_range(0.0, 1.0) = 0.6;

uniform float animation_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec3 ring_speed = vec3(1.0, 0.42, 0.29);

uniform bool use_normals = false;
uniform vec3 ring_normal_inner = vec3(0.0, 0.0, -1.0);
uniform vec3 ring_normal_middle = vec3(0.0, 1.0, 0.0);
uniform vec3 ring_normal_outer = vec3(1.0, 0.0, 0.0);
uniform vec3 ring_roll = vec3(0.0);

uniform vec3 ring_radius = vec3(1.6, 2.6, 3.6);
uniform vec3 ring_thickness = vec3(0.05, 0.065, 0.08);
uniform vec3 ring_height = vec3(0.3, 0.4, 0.5);
uniform ivec3 eye_counts = ivec3(8, 12, 16);

uniform float eye_size : hint_range(0.0, 3.0) = 1.0;
uniform float eye_flatten : hint_range(0.05, 1.0) = 0.4;
uniform float eye_offset : hint_range(-0.5, 0.5, 0.001) = 0.0;

uniform bool show_pupils = true;
uniform float pupil_size : hint_range(0.05, 1.0) = 0.45;
uniform vec3 look_direction = vec3(0.0, 0.0, -1.0);
uniform bool random_look = false;
uniform float random_look_spread : hint_range(0.0, 1.0) = 0.3;
uniform float random_look_rate : hint_range(0.0, 5.0) = 0.0;
uniform float random_seed = 0.0;

const int MAX_EYES = 32;
const int STEPS = 40;
const float BOUND_SKIP = 0.2;
const vec3 RAY_ORIGIN = vec3(0.0, 0.0, -15.0);

struct Ring {
	mat3 m;
	vec3 look;
	float radius;
	float thick;
	float height;
	float n;
	float ang_step;
	float inv_step;
	vec2 cs;
	float eye_dist;
	float eye_r;
	float dome_r;
	float dome_c;
	float gap;
	float eps;
	float pupil_r;
	float bmin;
	float bmax;
	float id;
	float rand_t;
};

vec3 hash3(vec3 p) {
	p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
			 dot(p, vec3(269.5, 183.3, 246.1)),
			 dot(p, vec3(113.5, 271.9, 124.6)));
	return fract(sin(p) * 43758.5453123);
}

vec3 randomDir(float ring_id, float eye_id, float seed, float t) {
	float k = floor(t);
	float f = smoothstep(0.0, 1.0, t - k);
	vec3 a = hash3(vec3(ring_id, eye_id, seed + k * 7.13));
	vec3 b = hash3(vec3(ring_id, eye_id, seed + (k + 1.0) * 7.13));
	return mix(a, b, f) * 2.0 - 1.0;
}

vec3 dynamicAxis(float t, vec3 seed) {
	return normalize(vec3(sin(t * seed.x), cos(t * seed.y), -cos(t * seed.z)));
}

mat3 rotMat(vec3 axis, float angle) {
	axis = normalize(axis);
	float c = cos(angle);
	float s = sin(angle);
	float t = 1.0 - c;
	return mat3(
		vec3(t * axis.x * axis.x + c, t * axis.x * axis.y + s * axis.z, t * axis.x * axis.z - s * axis.y),
		vec3(t * axis.x * axis.y - s * axis.z, t * axis.y * axis.y + c, t * axis.y * axis.z + s * axis.x),
		vec3(t * axis.x * axis.z + s * axis.y, t * axis.y * axis.z - s * axis.x, t * axis.z * axis.z + c));
}

mat3 normalBasis(vec3 nrm, float roll) {
	vec3 n = length(nrm) > 0.0001 ? normalize(nrm) : vec3(0.0, 0.0, 1.0);
	vec3 up = abs(n.y) < 0.99 ? vec3(0.0, 1.0, 0.0) : vec3(1.0, 0.0, 0.0);
	vec3 t = normalize(cross(up, n));
	vec3 b = cross(n, t);
	mat3 basis = mat3(
		vec3(t.x, b.x, n.x),
		vec3(t.y, b.y, n.y),
		vec3(t.z, b.z, n.z));
	float c = cos(roll);
	float s = sin(roll);
	mat3 rz = mat3(vec3(c, s, 0.0), vec3(-s, c, 0.0), vec3(0.0, 0.0, 1.0));
	return rz * basis;
}

mat3 ringMat(float t, vec3 s1, vec3 s2, float k1, float k2, vec3 nrm, float roll) {
	if (use_normals) {
		return normalBasis(nrm, roll);
	}
	return rotMat(dynamicAxis(t, s2), t * k2) * rotMat(dynamicAxis(t, s1), t * k1);
}

float clip_half(float d, vec3 p) {
	if (half_mode == 1) {
		d = max(d, p.z);
	} else if (half_mode == 2) {
		d = max(d, -p.z);
	}
	return d;
}

float eyeRadius(float radius, float thick, int eyes) {
	float n = float(clamp(eyes, 1, MAX_EYES));
	return max(min(radius * 0.12, TAU * (radius + thick) / n * 0.25) * eye_size, 0.0001);
}

float ringReach(float radius, float thick, float height, int eyes) {
	float er = eyeRadius(radius, thick, eyes);
	float rr = radius + thick + max(eye_offset + er * (eye_flatten + 0.03), 0.0);
	float zz = max(height + thick, er * 1.2);
	return sqrt(rr * rr + zz * zz) + er * 0.05 + 0.01;
}

Ring makeRing(mat3 m, float id, float rand_t, float radius, float thick, float height, int eyes) {
	Ring r;
	r.m = m;
	r.look = m * normalize(look_direction);
	r.radius = radius;
	r.thick = thick;
	r.height = height;

	float n = float(clamp(eyes, 1, MAX_EYES));
	r.n = n;
	r.ang_step = TAU / n;
	r.inv_step = n / TAU;
	r.cs = vec2(cos(r.ang_step), sin(r.ang_step));

	float outer = radius + thick;
	float er = eyeRadius(radius, thick, eyes);
	float h = er * eye_flatten;
	r.eye_r = er;
	r.dome_r = (er * er + h * h) / (2.0 * h);
	r.dome_c = h - r.dome_r;
	r.eye_dist = outer + eye_offset;
	r.gap = min(er * er / outer, thick * 1.5);
	r.eps = er * 0.03;
	r.pupil_r = er * pupil_size;

	r.bmin = radius - thick;
	r.bmax = ringReach(radius, thick, height, eyes);
	r.id = id;
	r.rand_t = rand_t;
	return r;
}

void evalEye(vec3 p, vec2 rad, float id, Ring r, inout vec2 res) {
	vec2 tan2 = vec2(-rad.y, rad.x);
	vec3 d = p - vec3(rad * r.eye_dist, 0.0);
	vec3 e = vec3(dot(d.xy, rad), dot(d.xy, tan2), d.z);

	float eye_d = max(length(e - vec3(r.dome_c, 0.0, 0.0)) - r.dome_r, -e.x - r.gap);
	if (eye_d < res.x) {
		res = vec2(eye_d, 2.0);
	}

	if (show_pupils && eye_d - r.eps < res.x) {
		vec3 l;
		if (random_look) {
			vec3 rv = randomDir(r.id, mod(id, r.n), random_seed, r.rand_t);
			l = vec3(1.0, rv.yz * random_look_spread);
		} else {
			l = vec3(dot(r.look.xy, rad), dot(r.look.xy, tan2), r.look.z);
		}
		l.x = max(l.x, 0.1);
		l = normalize(l);

		vec2 lat = l.yz * r.eye_r;
		vec3 pc = vec3(r.dome_c + sqrt(max(r.dome_r * r.dome_r - dot(lat, lat), 0.0)), lat);
		float pupil_d = max(eye_d - r.eps, length(e - pc) - r.pupil_r);
		if (pupil_d < res.x) {
			res = vec2(pupil_d, 3.0);
		}
	}
}

vec2 ringDist(vec3 q, Ring r) {
	float L = length(q);
	float db = max(L - r.bmax, r.bmin - L);
	if (db > BOUND_SKIP) {
		return vec2(db, 0.0);
	}

	vec3 p = r.m * q;
	float rho = length(p.xy);
	float dz = p.z - clamp(p.z, -r.height, r.height);
	vec2 res = vec2(length(vec2(rho - r.radius, dz)) - r.thick, 1.0);

	float i0 = floor(atan(p.y, p.x) * r.inv_step);
	float a0 = i0 * r.ang_step;
	vec2 rad = vec2(cos(a0), sin(a0));
	evalEye(p, rad, i0, r, res);

	rad = vec2(rad.x * r.cs.x - rad.y * r.cs.y, rad.x * r.cs.y + rad.y * r.cs.x);
	evalEye(p, rad, i0 + 1.0, r, res);

	res.x = clip_half(res.x, q);
	return res;
}

vec2 map(vec3 q, Ring a, Ring b, Ring c) {
	vec2 res = ringDist(q, a);
	vec2 rb = ringDist(q, b);
	if (rb.x < res.x) res = rb;
	vec2 rc = ringDist(q, c);
	if (rc.x < res.x) res = rc;
	return res;
}

vec3 calcNormal(vec3 p, Ring a, Ring b, Ring c) {
	const vec2 k = vec2(1.0, -1.0);
	const float h = 0.0015;
	return normalize(
		k.xyy * map(p + k.xyy * h, a, b, c).x +
		k.yyx * map(p + k.yyx * h, a, b, c).x +
		k.yxy * map(p + k.yxy * h, a, b, c).x +
		k.xxx * map(p + k.xxx * h, a, b, c).x);
}

void fragment() {
	vec2 resolution = vec2(1.0) / TEXTURE_PIXEL_SIZE;
	vec2 uv = UV * 2.0 - 1.0;
	uv.x *= resolution.x / resolution.y;
	vec3 ray_dir = normalize(vec3(uv * 0.7, 1.0));

	float reach = max(
		ringReach(ring_radius.x, ring_thickness.x, ring_height.x, eye_counts.x),
		max(ringReach(ring_radius.y, ring_thickness.y, ring_height.y, eye_counts.y),
			ringReach(ring_radius.z, ring_thickness.z, ring_height.z, eye_counts.z)));
	float b = dot(RAY_ORIGIN, ray_dir);
	float disc = b * b - (dot(RAY_ORIGIN, RAY_ORIGIN) - reach * reach);

	Ring r1;
	Ring r2;
	Ring r3;
	float material = 0.0;
	float tot_dist = 0.0;
	bool hit = false;

	if (disc >= 0.0) {
		float sq = sqrt(disc);
		float t_far = -b + sq;
		tot_dist = max(-b - sq, 0.0);

		float T = TIME * animation_speed;
		float rt = TIME * random_look_rate;
		r1 = makeRing(ringMat(T * ring_speed.x, vec3(1.2, 1.1, 1.63), vec3(1.6, 1.8, 1.05), 0.7, 1.3, ring_normal_inner, ring_roll.x),
					  0.0, rt, ring_radius.x, ring_thickness.x, ring_height.x, eye_counts.x);
		r2 = makeRing(ringMat(T * ring_speed.y + 2.5, vec3(0.9, 1.4, 1.77), vec3(1.3, 1.9, 0.85), 0.6, 0.2, ring_normal_middle, ring_roll.y),
					  1.0, rt, ring_radius.y, ring_thickness.y, ring_height.y, eye_counts.y);
		r3 = makeRing(ringMat(T * ring_speed.z + 4.1, vec3(1.7, 0.8, 1.25), vec3(1.5, 1.2, 1.9), 1.1, 0.4, ring_normal_outer, ring_roll.z),
					  2.0, rt, ring_radius.z, ring_thickness.z, ring_height.z, eye_counts.z);

		for (int i = 0; i < STEPS; i++) {
			vec2 m = map(RAY_ORIGIN + ray_dir * tot_dist, r1, r2, r3);
			if (m.x < 0.001) {
				hit = true;
				material = m.y;
				break;
			}
			tot_dist += m.x * 0.95;
			if (tot_dist > t_far) break;
		}
	}

	if (!hit) {
		COLOR = vec4(0.0, 0.0, 0.0, background_alpha);
	} else {
		vec3 pos = RAY_ORIGIN + ray_dir * tot_dist;
		vec3 n = calcNormal(pos, r1, r2, r3);
		vec3 light_dir = normalize(vec3(-0.4, 0.6, -1.0));

		vec3 base = gold_color.rgb;
		if (material > 2.5) {
			base = pupil_color.rgb;
		} else if (material > 1.5) {
			base = eye_color.rgb;
		}

		float diff = max(dot(n, light_dir), 0.0);
		vec3 h = normalize(light_dir - ray_dir);
		float spec = max(dot(n, h), 0.0);
		spec *= spec; spec *= spec; spec *= spec; spec *= spec; spec *= spec;
		if (material > 1.5) spec *= spec;
		float rim = 1.0 - max(dot(n, -ray_dir), 0.0);
		rim = rim * rim * rim;

		vec3 col = base * (0.25 + 0.85 * diff) + vec3(spec) * 0.6 + gold_color.rgb * rim * 0.3;
		COLOR = vec4(col, 1.0);
	}
}
