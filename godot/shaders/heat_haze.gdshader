shader_type canvas_item;

// Heat distortion settings
uniform float distortion_strength : hint_range(0.0, 0.05) = 0.008;
uniform float wave_speed : hint_range(0.0, 5.0) = 1.5;
uniform float wave_frequency : hint_range(0.0, 50.0) = 20.0;
uniform float vertical_frequency : hint_range(0.0, 20.0) = 8.0;

// Fade settings - effect is strongest at top, fades toward bottom
uniform float fade_start : hint_range(0.0, 1.0) = 0.0; // Top of effect region (0 = screen top)
uniform float fade_end : hint_range(0.0, 1.0) = 0.4;   // Bottom of effect region

// Screen texture for distortion
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// Calculate fade factor based on vertical position
	// Effect is strongest at top (near furnace), fades toward bottom
	float fade = 1.0 - smoothstep(fade_start, fade_end, uv.y);
	
	// Create organic heat shimmer using multiple sine waves
	// Horizontal distortion (primary heat wave)
	float time = TIME * wave_speed;
	
	// Multiple overlapping waves for more organic feel
	float wave1 = sin(uv.y * wave_frequency + time) * 0.5;
	float wave2 = sin(uv.y * wave_frequency * 1.7 + time * 1.3) * 0.3;
	float wave3 = sin(uv.y * wave_frequency * 0.5 + time * 0.7) * 0.2;
	
	// Vertical wave component (rising heat effect)
	float vertical_wave = sin(uv.x * vertical_frequency + time * 0.8) * 0.3;
	
	// Combine waves (fade factor makes offset 0 when outside effect region)
	float horizontal_offset = (wave1 + wave2 + wave3) * distortion_strength * fade;
	float vertical_offset = vertical_wave * distortion_strength * 0.5 * fade;
	
	// Add subtle noise-like variation using more sine waves
	float noise_x = sin(uv.x * 50.0 + uv.y * 30.0 + time * 2.0) * 0.1;
	float noise_y = cos(uv.x * 40.0 + uv.y * 35.0 + time * 1.5) * 0.1;
	
	horizontal_offset += noise_x * distortion_strength * fade;
	vertical_offset += noise_y * distortion_strength * 0.3 * fade;
	
	// Apply distortion to UV coordinates (offset is 0 when fade is 0)
	vec2 distorted_uv = uv + vec2(horizontal_offset, vertical_offset);
	
	// Clamp to screen bounds to prevent artifacts
	distorted_uv = clamp(distorted_uv, vec2(0.001), vec2(0.999));
	
	// Sample the distorted screen
	COLOR = texture(screen_texture, distorted_uv);
}
