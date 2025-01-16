shader_type canvas_item;

uniform bool is_gray = true; // 添加控制开关

void fragment() {
    // 获取当前像素的颜色
    vec4 texture_color = texture(TEXTURE, UV);
    
    if (is_gray) {
        // 计算灰度值
        float gray = dot(texture_color.rgb, vec3(0.299, 0.587, 0.114));
        COLOR = vec4(vec3(gray), texture_color.a);
    } else {
        // 保持原始颜色
        COLOR = texture_color;
    }
}