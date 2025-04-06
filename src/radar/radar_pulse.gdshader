shader_type canvas_item;

uniform float time : hint_range(0.0, 1.0);
uniform float pulse_size;
uniform vec4 pulse_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);

void fragment() {
    vec2 pixel_uv = floor(UV * pulse_size) + 0.5; // this snaps the pixel to the uv grid resolution

    vec2 center = vec2(pulse_size * 0.5);
    float dist = length(pixel_uv - center);

    float pulse_1_radius = (pulse_size * 0.5) * time;
    float pulse_1_alpha = 1.0 - time;
    float pulse_2_radius = (pulse_size * 0.5) * time - pulse_size * 0.1;
    float pulse_2_alpha = 1.0 - time - 0.1;

    if (abs(dist - pulse_1_radius) < 0.5) {
        COLOR = pulse_color;
        COLOR.a = pulse_1_alpha;
    } else if (abs(dist - pulse_2_radius) < 0.5) {
        COLOR = pulse_color;
        COLOR.a = pulse_2_alpha;
    } else {
        discard;
    }
}
