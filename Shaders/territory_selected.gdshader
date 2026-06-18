shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, unshaded;

uniform vec4 highlight_color : source_color = vec4(0.133, 0.227, 0.643, 0.4);
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;

void fragment() {
	float pulse = sin(TIME * pulse_speed) * 0.15 + 0.85;
	ALBEDO = highlight_color.rgb * highlight_color.a * pulse;
	ALPHA = 1.0;
}