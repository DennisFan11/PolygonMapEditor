shader_type canvas_item;
uniform float rand_time = 0.0;
void vertex(){
	VERTEX.x += sin(TIME*1.5 + rand_time) * pow(VERTEX.y, 2.0) /225.0;
	//VERTEX.x += sin(TIME) * VERTEX.y /15.0;
}
void fragment() {
	//COLOR.rg = UV;
	//COLOR.b = 0.0;
}
