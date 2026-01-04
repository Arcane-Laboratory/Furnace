shader_type canvas_item;

// Vignette settings
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Bloom settings (simulated bloom for gl_compatibility)
uniform float bloom_threshold : hint_range(0.0, 1.0) = 0.7;
uniform float bloom_intensity : hint_range(0.0, 2.0) = 0.3;
uniform float bloom_spread : hint_range(0.0, 10.0) = 3.0;

// Screen texture for reading the rendered scene
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// Get luminance of a color
float get_luminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

// Simple box blur for bloom approximation
vec3 blur_sample(sampler2D tex, vec2 uv, vec2 pixel_size, float spread) {
	vec3 color = vec3(0.0);
	float total_weight = 0.0;
	
	// 9-tap box blur
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			vec2 offset = vec2(float(x), float(y)) * pixel_size * spread;
			vec3 sample_color = texture(tex, uv + offset).rgb;
			
			// Weight by luminance above threshold (only bright pixels bloom)
			float lum = get_luminance(sample_color);
			float bright_weight = max(0.0, lum - bloom_threshold);
			
			color += sample_color * bright_weight;
			total_weight += bright_weight;
		}
	}
	
	if (total_weight > 0.0) {
		return color / total_weight;
	}
	return vec3(0.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_size = 1.0 / vec2(textureSize(screen_texture, 0));
	
	// Sample the original screen color
	vec4 original = texture(screen_texture, uv);
	vec3 color = original.rgb;
	
	// === BLOOM EFFECT ===
	// Multi-pass blur approximation for bloom glow
	vec3 bloom = vec3(0.0);
	
	// Sample at multiple scales for a softer bloom
	bloom += blur_sample(screen_texture, uv, pixel_size, bloom_spread * 1.0) * 0.5;
	bloom += blur_sample(screen_texture, uv, pixel_size, bloom_spread * 2.0) * 0.3;
	bloom += blur_sample(screen_texture, uv, pixel_size, bloom_spread * 4.0) * 0.2;
	
	// Add bloom to original color
	color += bloom * bloom_intensity;
	
	// === VIGNETTE EFFECT ===
	// Calculate distance from center (normalized to 0-1 range)
	vec2 center = uv - vec2(0.5);
	float dist = length(center) * 1.414; // Normalize diagonal to 1.0
	
	// Create smooth vignette falloff
	float vignette_start = 1.0 - vignette_intensity;
	float vignette = smoothstep(vignette_start, vignette_start - vignette_softness, dist);
	
	// Apply vignette (darken edges)
	color = mix(vignette_color.rgb, color, vignette);
	
	// Output final color
	COLOR = vec4(color, original.a);
}
