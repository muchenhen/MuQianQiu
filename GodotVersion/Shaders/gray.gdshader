shader_type canvas_item;
render_mode unshaded;

uniform bool is_gray = true; // 添加控制开关

void fragment() {
    // 获取当前像素的颜色
    vec4 texture_color = texture(TEXTURE, UV);

    if (is_gray) {
        // 计算灰度值
        float gray = dot(texture_color.rgb, vec3(0.299, 0.587, 0.114));
        // 关键修改：将 COLOR（节点调制颜色）乘入最终输出，确保父节点的 modulate alpha 生效
        // 修复变暗问题：忽略 RGB 调制，只保留 Alpha
        COLOR = vec4(vec3(gray), texture_color.a * COLOR.a);
    } else {
        // 保持原始颜色
        // 修复变暗问题：忽略 RGB 调制，只保留 Alpha
        COLOR = vec4(texture_color.rgb, texture_color.a * COLOR.a);
    }
}
