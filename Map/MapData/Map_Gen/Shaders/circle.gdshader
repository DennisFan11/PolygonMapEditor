shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (length(UV-vec2(0.5, 0.5)) > 0.5){
		discard;
	}
	COLOR = texture(SCREEN_TEXTURE, UV);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
