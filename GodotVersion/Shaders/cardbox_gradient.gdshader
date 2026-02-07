shader_type canvas_item;

uniform vec4 center_color : source_color = vec4(0.06, 0.05, 0.04, 0.25);
uniform vec4 edge_color : source_color = vec4(0.04, 0.04, 0.06, 0.35);
uniform vec4 border_color : source_color = vec4(0.7, 0.6, 0.35, 0.3);
uniform float border_width : hint_range(0.0, 10.0) = 1.5;
uniform float inner_shadow_strength : hint_range(0.0, 1.0) = 0.2;
uniform float corner_radius : hint_range(0.0, 50.0) = 12.0;
uniform float gradient_falloff : hint_range(0.1, 2.0) = 1.2;

void fragment() {
    vec2 uv = UV;
    vec2 size = TEXTURE_PIXEL_SIZE;
    vec2 pixel_size = 1.0 / size;

    // 计算到中心的距离（径向渐变）
    vec2 center = vec2(0.5, 0.5);
    float dist = length(uv - center);

    // 径向渐变背景
    float gradient = smoothstep(0.0, gradient_falloff * 0.5, dist);
    vec4 gradient_color = mix(center_color, edge_color, gradient);

    // 内阴影效果
    float shadow_top = smoothstep(0.0, pixel_size.y * 40.0, uv.y);
    float shadow_bottom = smoothstep(1.0, 1.0 - pixel_size.y * 40.0, uv.y);
    float shadow_left = smoothstep(0.0, pixel_size.x * 40.0, uv.x);
    float shadow_right = smoothstep(1.0, 1.0 - pixel_size.x * 40.0, uv.x);

    float inner_shadow = 1.0 - (1.0 - shadow_top) * (1.0 - shadow_bottom) * (1.0 - shadow_left) * (1.0 - shadow_right);
    inner_shadow = mix(1.0, inner_shadow, inner_shadow_strength);

    gradient_color.rgb *= inner_shadow;

    // 柔和边框效果
    float border = 0.0;
    float border_pixel = border_width * pixel_size.x;
    float border_softness = 3.0 * pixel_size.x;

    // 上边框
    border += smoothstep(border_pixel + border_softness, border_pixel, uv.y);
    // 下边框
    border += smoothstep(1.0 - uv.y, 1.0 - uv.y - border_softness, border_pixel);
    // 左边框
    border += smoothstep(border_pixel + border_softness, border_pixel, uv.x);
    // 右边框
    border += smoothstep(1.0 - uv.x, 1.0 - uv.x - border_softness, border_pixel);

    // 圆角处理
    if (corner_radius > 0.0) {
        float radius = corner_radius * pixel_size.x;
        vec2 corner_uv = vec2(
            min(uv.x, 1.0 - uv.x),
            min(uv.y, 1.0 - uv.y)
        );
        float corner_dist = length(corner_uv - vec2(radius));
        float corner_mask = smoothstep(radius - pixel_size.x * 2.0, radius, corner_dist);

        // 在角上应用圆角
        if (corner_uv.x < radius && corner_uv.y < radius) {
            border *= corner_mask;
        }
    }

    // 混合边框和背景
    vec4 final_color = mix(gradient_color, border_color, clamp(border, 0.0, 1.0));

    COLOR = final_color;
}
