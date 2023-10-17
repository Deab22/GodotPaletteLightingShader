//Decode Lighting

shader_type canvas_item;
render_mode unshaded;

//uniform sampler2D palette : hint_default_black, filter_nearest;
uniform sampler2D gradient : hint_default_black, filter_nearest;
uniform int palette_size = 42;
uniform int palette_height = 9;
uniform float normal_modifier : hint_range(0, 1) = 1;
uniform float dither_modifier : hint_range(0, 0.5) = 0;
uniform bool use_light_curve = false;
uniform sampler2D light_curve : repeat_disable;//default: (x=0, y=0), (x=1, y=1)
uniform bool use_normal_curve = false;
uniform sampler2D normal_curve : repeat_disable;//default: (x=0, y=1), (x=1, y=1)


bool dither(vec2 uv, vec2 pixel_size) {//edit this function to make new dithering patterns
	bool bool_x = (int(round(uv.x / pixel_size.x + 0.5)) % 2 == 1);
	bool bool_y = (int(round(uv.y / pixel_size.y + 0.5)) % 2 == 1);
	if(bool_x != bool_y) return true;
	return false;
}

float dither_palette(float light, bool dither) {
	
	float closest_color_border = round(float(palette_height) * light) / float(palette_height);
	
	float border_distance = light - closest_color_border;
	if(border_distance < 0.0) border_distance = -border_distance;
	
	if(border_distance < 1.0 / float(palette_height) / 2.0 * dither_modifier) {
		if(dither) {
			return closest_color_border + 1.0 / float(palette_height) * dither_modifier;
		} else {
			return closest_color_border - 1.0 / float(palette_height) * dither_modifier;
		}
	}
	
	return light;
}


void fragment() {
	vec4 input_color = texture(TEXTURE, UV);
	float input_id = round(input_color.g * float(palette_size));
	
	float input_uv_pos = (input_id + 0.5) / float(palette_size);
	
	float light = (texture(TEXTURE, UV).r * normal_modifier) + (1.0 - normal_modifier) / 2.0;
	float light_strength = texture(TEXTURE, UV).b;
	
	if(use_light_curve){
		light_strength = texture(light_curve, vec2(light_strength)).r;
	}
	
	if(use_normal_curve){
		light = light * texture(normal_curve, vec2(light)).r;
	}
	
	float light_final = light * light_strength;
	
	float light_dither = dither_palette(light_final, dither(UV, TEXTURE_PIXEL_SIZE));
	
	vec4 lit_color = texture(gradient, vec2(input_uv_pos, light_dither));
	
	COLOR = lit_color;
	
	//COLOR = vec4(light_strength, light_strength, light_strength, 1); //only lights
	//COLOR = vec4(light, light, light, 1);                            //only normal
	//COLOR = vec4(input_uv_pos, input_uv_pos, input_uv_pos, 1);       //only color IDs
}