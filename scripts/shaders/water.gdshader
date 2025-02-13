shader_type spatial;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

// Water color
uniform vec4 out_color: source_color = vec4(0.0, 0.2, 1.0, 1.0);
// Amount of height for each triangle
uniform float amount: hint_range(0.2, 5.0, 0.1) = 0.8;
// The speed of the triangles' height change
uniform float speed: hint_range(0.1, 5.0, 0.1) = 1.0;
// Beer factor (if set to 0.0 the alpha will be the out_color's alpha)
uniform float beer_factor = 0.2;

uniform float metallic = 0.6;
uniform float specular = 0.5;
uniform float roughness = 0.2;

// Generates an offset value based on position and time
float generateOffset(float x, float z, float val1, float val2, float time) {
    float radiansX = ((mod(x + z * x * val1, amount) / amount)
                     + (time * speed) * mod(x * 0.8 + z, 1.5))
                     * 2.0 * 3.14;
                     
    float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount)
                     + (time * speed) * 2.0 * mod(x, 2.0))
                     * 2.0 * 3.14;
    
    return amount * 0.5 * (sin(radiansZ) * cos(radiansX));
}

// Applies distortion to the vertex based on its position and the time
vec3 applyDistortion(vec3 vertex, float time) {
    float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
    float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
    float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);
    
    return vertex + vec3(xd, yd, zd);
}

void vertex() {
    // Apply distortion to vertex positions
    VERTEX = applyDistortion(VERTEX, TIME * 0.1);
}

void fragment() {
    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
    METALLIC = metallic;
    SPECULAR = specular;
    ROUGHNESS = roughness;
    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    ALBEDO = vec3(depth);
    
    // Force full visibility (no depth fade)
    ALPHA = 1.0;
}

