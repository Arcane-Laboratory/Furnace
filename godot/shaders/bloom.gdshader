shader_type canvas_item;

// Bloom post-processing shader for gl_compatibility renderer
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// Bloom parameters (tunable in editor)
uniform float bloom_threshold : hint_range(0.0, 1.0) = 0.3;
uniform float bloom_intensity : hint_range(0.0, 5.0) = 3.0;
uniform float blur_radius : hint_range(0.0, 10.0) = 6.0;
uniform float bloom_saturation : hint_range(0.0, 2.0) = 1.4;
uniform float warm_color_boost : hint_range(0.0, 2.0) = 1.8;

// Debug: 0=normal, 1=bloom only, 2=bright extraction only
uniform int debug_mode : hint_range(0, 2) = 0;

const int BLUR_SAMPLES = 12;

float get_luminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

float get_warmth(vec3 color) {
	float warmth = color.r * 0.7 + color.g * 0.2 - color.b * 0.4;
	return max(0.0, warmth);
}

vec3 extract_bright(vec3 color, float threshold) {
	float luminance = get_luminance(color);
	float warmth = get_warmth(color);
	float effective_brightness = luminance + warmth * warm_color_boost * 0.4;
	float soft_threshold = threshold * 0.6;
	float contribution = smoothstep(soft_threshold, threshold + 0.2, effective_brightness);
	return color * contribution;
}

vec3 blur_sample(vec2 uv, vec2 pixel_size, float radius) {
	vec3 result = vec3(0.0);
	float total_weight = 0.0;
	
	for (int i = 0; i < BLUR_SAMPLES; i++) {
		float angle = float(i) * 6.28318530718 / float(BLUR_SAMPLES);
		
		for (int ring = 1; ring <= 4; ring++) {
			float dist = radius * float(ring) / 4.0;
			vec2 offset = vec2(cos(angle), sin(angle)) * dist * pixel_size;
			
			vec3 sample_color = texture(screen_texture, uv + offset).rgb;
			vec3 bright = extract_bright(sample_color, bloom_threshold);
			
			float weight = 1.0 / (float(ring) * 0.5 + 0.5);
			result += bright * weight;
			total_weight += weight;
		}
	}
	
	vec3 center_color = texture(screen_texture, uv).rgb;
	vec3 center_bright = extract_bright(center_color, bloom_threshold);
	result += center_bright * 3.0;
	total_weight += 3.0;
	
	return result / total_weight;
}

void fragment() {
	vec2 pixel_size = 1.0 / vec2(textureSize(screen_texture, 0));
	vec4 original = texture(screen_texture, SCREEN_UV);
	
	vec3 bloom = blur_sample(SCREEN_UV, pixel_size, blur_radius);
	
	float bloom_lum = get_luminance(bloom);
	vec3 bloom_saturated = mix(vec3(bloom_lum), bloom, bloom_saturation);
	bloom_saturated *= bloom_intensity;
	
	vec3 final_color;
	
	if (debug_mode == 2) {
		// Show only extracted bright pixels
		final_color = extract_bright(original.rgb, bloom_threshold) * 2.0;
	} else if (debug_mode == 1) {
		// Show only bloom
		final_color = bloom_saturated;
	} else {
		// Normal: original + bloom with tone mapping
		final_color = original.rgb + bloom_saturated;
		final_color = final_color / (final_color + vec3(1.0));
		final_color = pow(final_color, vec3(1.0 / 1.05));
	}
	
	COLOR = vec4(final_color, 1.0);
}
