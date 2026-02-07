shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(1.0, 0.9, 0.5, 1.0);
uniform vec4 bottom_color : source_color = vec4(1.0, 0.7, 0.2, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.4, 0.5);
uniform float glow_strength : hint_range(0.0, 2.0) = 0.8;
uniform float glow_size : hint_range(0.0, 20.0) = 8.0;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform vec2 shadow_offset : hint_range(-20.0, 20.0) = vec2(2.0, 2.0);
uniform float shadow_blur : hint_range(0.0, 10.0) = 3.0;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE;
    vec2 uv = UV;

    // 获取原始文字alpha
    float text_alpha = texture(TEXTURE, uv).a;

    if (text_alpha < 0.01) {
        COLOR = vec4(0.0);
        return;
    }

    // 垂直渐变
    vec4 gradient_color = mix(top_color, bottom_color, uv.y);
    gradient_color.a = text_alpha;

    // 发光效果
    float glow = 0.0;
    float glow_pixel = glow_size * size.x;
    int samples = 8;

    for (int i = 1; i <= samples; i++) {
        float offset = float(i) * glow_pixel / float(samples);
        glow += texture(TEXTURE, uv + vec2(0.0, offset)).a;
        glow += texture(TEXTURE, uv - vec2(0.0, offset)).a;
        glow += texture(TEXTURE, uv + vec2(offset, 0.0)).a;
        glow += texture(TEXTURE, uv - vec2(offset, 0.0)).a;
    }
    glow /= float(samples) * 4.0;
    glow = smoothstep(0.0, 1.0, glow) * glow_strength;

    // 阴影效果
    vec2 shadow_uv = uv + shadow_offset * size;
    float shadow_alpha = texture(TEXTURE, shadow_uv).a;

    // 混合阴影、发光和渐变
    vec4 final_color = vec4(0.0);

    // 首先添加阴影
    final_color.rgb = shadow_color.rgb;
    final_color.a = shadow_alpha * shadow_color.a * (1.0 - text_alpha);

    // 添加发光
    vec4 glow_layer = glow_color;
    glow_layer.a = glow * glow_color.a * (1.0 - text_alpha);
    final_color = blend_add(final_color, glow_layer);

    // 添加渐变文字
    final_color = blend_add(final_color, gradient_color);

    COLOR = final_color;
}
