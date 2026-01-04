shader_type canvas_item;

// Posterization shader with warm, earthy color palette
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int color_levels : hint_range(2, 16) = 8;

// Pre-set palette with 8 warm, earthy colors matching furnace theme
const vec3 palette[8] = vec3[](
	vec3(0.12, 0.12, 0.14),  // Dark background
	vec3(0.3, 0.2, 0.15),    // Dark brown
	vec3(0.5, 0.35, 0.25),   // Medium brown
	vec3(0.7, 0.5, 0.3),     // Light brown
	vec3(0.9, 0.4, 0.1),     // Orange/red (furnace color)
	vec3(0.95, 0.6, 0.2),    // Bright orange
	vec3(0.8, 0.7, 0.5),     // Warm beige
	vec3(0.95, 0.9, 0.7)     // Light cream
);

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	// Quantize colors
	float levels = float(color_levels);
	vec3 quantized = floor(color.rgb * levels) / levels;
	
	// Find nearest palette color
	vec3 nearest_color = palette[0];
	float min_distance = distance(quantized, palette[0]);
	
	for (int i = 1; i < 8; i++) {
		float dist = distance(quantized, palette[i]);
		if (dist < min_distance) {
			min_distance = dist;
			nearest_color = palette[i];
		}
	}
	
	COLOR = vec4(nearest_color, color.a);
}
