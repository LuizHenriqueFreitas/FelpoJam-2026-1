shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, unshaded;

uniform vec4 color : source_color = vec4(1.0, 0.8, 0.2, 0.35);
uniform float border_width : hint_range(0.0, 0.5) = 0.08;
uniform float border_strength : hint_range(0.0, 1.0) = 0.9;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	vec2 uv_centered = UV - vec2(0.5);
	float dist = length(uv_centered) * 2.0;

	if (dist > 1.0) discard;

	// Pulsa levemente para dar feedback visual
	float pulse = sin(TIME * pulse_speed) * 0.15 + 0.85;
	float alpha = color.a * pulse;

	float border = smoothstep(1.0 - border_width, 1.0, dist);
	alpha = mix(alpha, border_strength, border);

	ALBEDO = color.rgb;
	ALPHA = alpha;
}
