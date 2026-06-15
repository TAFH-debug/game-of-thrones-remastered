shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, unshaded;

uniform vec4 highlight_color : source_color = vec4(0.133, 0.227, 0.643, 0.4);
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;

uniform bool active = false;
void fragment() {
	if (!active) {
		ALBEDO = vec3(0.0);
		ALPHA = 0.0; 
	}
	else {
	    float pulse = sin(TIME * pulse_speed) * 0.15 + 0.85;
	    ALBEDO = highlight_color.rgb;
	    ALPHA  = highlight_color.a;
	}
}