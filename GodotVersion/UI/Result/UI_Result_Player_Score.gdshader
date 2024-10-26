# 在 Label 节点中添加 ShaderMaterial，然后将以下代码保存为 .gdshader 文件并应用

shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 5.0) = 1.0;
uniform float glow_size : hint_range(0.0, 5.0) = 2.0;
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);
    
    // 计算发光
    float alpha = 0.0;
    for(float x = -glow_size; x <= glow_size; x++) {
        for(float y = -glow_size; y <= glow_size; y++) {
            vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE;
            alpha += texture(TEXTURE, UV + offset).a;
        }
    }
    alpha = alpha / ((glow_size * 2.0 + 1.0) * (glow_size * 2.0 + 1.0));
    
    // 混合原始颜色和发光颜色
    vec4 glow = vec4(glow_color.rgb, alpha * glow_strength);
    vec4 final_color = mix(glow, current_color, current_color.a);
    
    // 应用 alpha 阈值
    COLOR = final_color;
    if (COLOR.a < alpha_threshold) {
        COLOR.a = 0.0;
    }
}