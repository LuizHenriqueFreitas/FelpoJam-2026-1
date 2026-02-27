shader_type canvas_item;

uniform sampler2D mascara_tex : source_color;
uniform sampler2D fundo_vazio_tex : source_color;
uniform float percentual : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 mascara = texture(mascara_tex, UV);
	
	if (mascara.a < 0.1) {
		COLOR = vec4(0.0);
	} else if (UV.y < 1.0 - percentual) {
		COLOR = texture(fundo_vazio_tex, UV);
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}