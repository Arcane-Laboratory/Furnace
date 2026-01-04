shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float threshold : hint_range(0.0, 2.0) = 0.1;
uniform float intensity : hint_range(0.0, 5.0) = 5.0;
uniform float size : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	
	vec4 bloom = vec4(0.0);
	float sample_count = 0.0;
	
	float step = size * 0.005;
	
	for (float i = -4.0; i <= 4.0; i += 1.0) {
		vec2 offset_x = vec2(i * step, 0.0);
		vec2 offset_y = vec2(0.0, i * step);
		
		vec2 uv_x = SCREEN_UV + offset_x;
		vec2 uv_y = SCREEN_UV + offset_y;
		
		if (uv_x.x >= 0.0 && uv_x.x <= 1.0 && uv_x.y >= 0.0 && uv_x.y <= 1.0) {
			vec4 sample_x = texture(SCREEN_TEXTURE, uv_x);
			float bright_x = dot(sample_x.rgb, vec3(0.299, 0.587, 0.114));
			if (bright_x > threshold) {
				float weight = 1.0 / (1.0 + abs(i) * 0.5);
				bloom += sample_x * weight;
				sample_count += weight;
			}
		}
		
		if (uv_y.x >= 0.0 && uv_y.x <= 1.0 && uv_y.y >= 0.0 && uv_y.y <= 1.0) {
			vec4 sample_y = texture(SCREEN_TEXTURE, uv_y);
			float bright_y = dot(sample_y.rgb, vec3(0.299, 0.587, 0.114));
			if (bright_y > threshold) {
				float weight = 1.0 / (1.0 + abs(i) * 0.5);
				bloom += sample_y * weight;
				sample_count += weight;
			}
		}
	}
	
	if (sample_count > 0.0) {
		bloom /= sample_count;
		bloom *= intensity;
		color = color + bloom;
	}
	
	COLOR = color;
}
