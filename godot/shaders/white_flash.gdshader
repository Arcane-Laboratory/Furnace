shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	// Add white based on flash_amount
	color.rgb += vec3(flash_amount);
	
	COLOR = color;
}
