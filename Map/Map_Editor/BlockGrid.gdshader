shader_type canvas_item;

uniform vec2 BlockSize = vec2(100.0, 100.0);  // 定義每個方塊的大小
uniform float WIDTH = 0.025;                    // 定義邊線的寬度

varying mat4 world_to_screen;
varying mat4 screen_to_world;

void vertex() {
    // 將螢幕空間與世界空間的轉換矩陣準備好
    world_to_screen = SCREEN_MATRIX * CANVAS_MATRIX; 
    screen_to_world = inverse(world_to_screen); 
}

void fragment() {
    vec2 uv = SCREEN_UV; 
    
    // 將 uv 從螢幕空間轉換到世界空間
    uv = uv * 2.0 - 1.0; 
    uv = (screen_to_world * vec4(uv, 0.0, 1.0)).xy;

    // 計算固定在網格上的 uv
    vec2 fixed_uv = floor(uv / BlockSize) * BlockSize;
	fixed_uv.x += BlockSize.x;
    
    // 計算與方塊邊界的距離
    vec2 dist_to_border = abs(uv - fixed_uv);

    // 檢查是否在邊界寬度範圍內
    if (dist_to_border.x < WIDTH || dist_to_border.y < WIDTH) {
        COLOR = vec4(0.5);
    //} else if (distance(uv, fixed_uv) <= 10.0) {
        //COLOR.rgb = vec3(0.0, 1.0, 0.0);  // 顯示綠色在距離 10 內的區域
    } else {
        discard;  // 若不在邊界內則丟棄像素
    }
}
