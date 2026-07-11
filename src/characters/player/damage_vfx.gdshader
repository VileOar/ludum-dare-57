shader_type canvas_item;

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 0.2, 0.2, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    tex.rgb = mix(tex.rgb, flash_color.rgb, flash * tex.a);

    COLOR = tex;
}
