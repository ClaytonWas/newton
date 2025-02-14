shader_type spatial;
render_mode cull_front, unshaded;

uniform vec4 outline_color : source_color;
uniform float outline_width = 0.05; // World-space outline thickness

void vertex() {
    vec3 view_normal = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
    vec3 offset = normalize(view_normal) * outline_width;

    VERTEX += offset; // Push vertices outward

    POSITION = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}
