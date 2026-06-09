shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx, vertex_lighting;

uniform vec4 smoke_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform sampler2D noise_texture : repeat_enable;
uniform float smoke_speed = 0.5;
uniform float Density : hint_range(0.0, 5.0) = 1.0;
uniform float edge_fade_power = 2.0;

void vertex() {
	// Делаем частицы всегда повернутыми к камере (Billboard эффект), 
	// если это не настроено в самой системе частиц.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0], 
		INV_VIEW_MATRIX[1], 
		INV_VIEW_MATRIX[2], 
		MODEL_MATRIX[3]
	);
	
	// Передаем цвет из GPUParticles3D (анимация затухания, размер и т.д.)
	COLOR = COLOR;
}

void fragment() {
	// Движение шума со временем
	vec2 moving_uv = UV + vec2(TIME * smoke_speed * 0.1, TIME * smoke_speed * -0.2);
	vec4 noise = texture(noise_texture, moving_uv);
	
	// Плавное угасание к краям меша (чтобы дым не выглядел как квадрат)
	float circle_dist = distance(UV, vec2(0.5));
	float edge_fade = smoothstep(0.5, 0.1, circle_dist);
	edge_fade = pow(edge_fade, edge_fade_power);
	
	// Итоговый цвет и альфа-канал
	ALBEDO = smoke_color.rgb * COLOR.rgb;
	
	// Комбинируем шум, цвет вершин частицы, плотность и плавные края
	float alpha_out = noise.r * COLOR.a * edge_fade * Density;
	ALPHA = clamp(alpha_out, 0.0, 1.0);
	
	// Небольшая шероховатость, чтобы дым не бликовал как металл
	ROUGHNESS = 0.9;
}