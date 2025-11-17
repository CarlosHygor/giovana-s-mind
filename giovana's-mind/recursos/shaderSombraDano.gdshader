shader_type canvas_item;

uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec4 flash = vec4(1.0, 0.1, 0.1, 1.0); // piscada vermelha
    COLOR = mix(tex, flash, flash_strength) * tex.a;
}
