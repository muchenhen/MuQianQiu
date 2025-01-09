shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float blur_amount : hint_range(0, 20) = 5.0;

// 随机函数
float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 tex_size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 pixel_size = 1.0 / tex_size;

    vec4 color = vec4(0.0);
    float total_weight = 0.0;

    // 增加采样范围和密度
    const int kernel_size = 12;
    const float noise_amount = 0.1;

    // 主采样循环
    for(int x = -kernel_size; x <= kernel_size; x++) {
        for(int y = -kernel_size; y <= kernel_size; y++) {
            vec2 offset_factor = vec2(float(x), float(y)) / float(kernel_size);
            float dist_squared = dot(offset_factor, offset_factor);

            // 改进的权重计算
            float weight = exp(-dist_squared * 1.5);

            // 添加随机抖动减少规则性
            vec2 noise = vec2(rand(SCREEN_UV + offset_factor),
                            rand(SCREEN_UV - offset_factor)) * noise_amount;

            // 计算采样偏移
            vec2 offset = (vec2(float(x), float(y)) + noise) * pixel_size * blur_amount;

            // 主采样点
            vec4 sample_color = texture(SCREEN_TEXTURE, SCREEN_UV + offset);
            color += sample_color * weight;

            // 额外采样点，填充间隙
            vec2 sub_offset = offset * 0.5;
            vec4 sub_sample = texture(SCREEN_TEXTURE, SCREEN_UV + sub_offset);
            color += sub_sample * (weight * 0.5);

            total_weight += weight * 1.5;
        }
    }

    // 归一化输出
    COLOR = color / total_weight;
}