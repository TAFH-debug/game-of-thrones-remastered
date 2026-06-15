shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, unshaded;

uniform vec4 border_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);
uniform float border_width : hint_range(0.0, 0.5) = 0.08;
uniform float glow_falloff : hint_range(0.5, 8.0) = 3.0;
uniform float noise_scale : hint_range(1.0, 20.0) = 6.0;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.35;
uniform float noise_speed : hint_range(0.0, 2.0) = 0.4;
uniform sampler2D noise_texture : hint_default_white;
uniform bool active = false;

float edge_dist(vec2 uv) {
    vec2 d = min(uv, 1.0 - uv);
    return min(d.x, d.y);
}

void fragment() {
	if (!active) {
		ALBEDO = vec3(0.0);
		ALPHA = 0.0;
	} 
	else {
		float dist = edge_dist(UV);
		
		vec2 noise_uv = UV * noise_scale + vec2(-1.0, -1.0) * TIME * noise_speed;
		float noise = texture(noise_texture, noise_uv).r;
		
		float perturbed = dist - noise * noise_strength * border_width;
		
		float glow = exp(-perturbed * glow_falloff / border_width);
		glow = clamp(glow, 0.0, 1.0);
		
		float border = 1.0 - smoothstep(0.0, border_width, perturbed);
		
		float alpha = max(border, glow * 0.7) * border_color.a;
		
		ALBEDO = border_color.rgb;
		ALPHA = alpha;
		EMISSION = border_color.rgb * glow * 1.5;
	}

}