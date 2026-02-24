shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, unshaded;

uniform vec4 color : source_color = vec4(0.3, 0.6, 1.0, 0.25);
uniform float border_width : hint_range(0.0, 0.5) = 0.04;
uniform float border_strength : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	// UV vai de 0 a 1, centro em 0.5
	vec2 uv_centered = UV - vec2(0.5);
	float dist = length(uv_centered) * 2.0; // 0 no centro, 1 na borda

	// Descarta fora do círculo
	if (dist > 1.0) discard;

	float alpha = color.a;

	// Borda mais visível
	float border = smoothstep(1.0 - border_width, 1.0, dist);
	alpha = mix(alpha, border_strength, border);

	ALBEDO = color.rgb;
	ALPHA = alpha;
}
