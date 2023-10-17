//Encode Lighting:

shader_type canvas_item;

uniform sampler2D palette : hint_default_black, filter_nearest;
uniform int palette_size = 42;

void fragment() {
	
	vec4 pixel_color = texture(TEXTURE, UV);
	
	float closest_distance = distance(vec4(0), vec4(1));
	int closest_index = 0;
	
	for (int i = 0; i < palette_size; i++) {
		vec4 palette_color = texture(palette, vec2((float(i) + 0.5) / float(palette_size), .0));
		float palette_distance = distance(palette_color, pixel_color);
		if (palette_distance < closest_distance) {
			closest_distance = palette_distance;
			closest_index = i;
		}
	}
	
	COLOR = vec4(0.5, 0.5, 0.0, pixel_color.a);
	COLOR.g = float(closest_index) / float(palette_size);
	//Map albedo to palette ID, store ID in green channel
}

void light() {
	float cNdotL = dot(NORMAL, LIGHT_DIRECTION);
	float modifier = 1.0;
	//if(cNdotL < 0.0) modifier = 0.6; //different strengths for light and shadow?
	float intensity = modifier * LIGHT_ENERGY * cNdotL;
	LIGHT = vec4(0, 0, 0, LIGHT_COLOR.a);
	LIGHT.r = intensity;    //Store single pixel brightness in red channel
	LIGHT.b = LIGHT_COLOR.a;//Store opacity of light source in blue channel
}