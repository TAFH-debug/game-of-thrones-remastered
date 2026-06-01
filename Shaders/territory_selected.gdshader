shader_type spatial;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform bool active = false;

void fragment() {
	if (!active) {
		vec4 color = texture(sprite_texture, UV);
		ALBEDO = color.rgb;
		ALPHA = color.a;
	}
	else {
		vec4 color = texture(sprite_texture, UV);
		ALBEDO = UV.xyx;
		ALPHA = color.a;
	}
}