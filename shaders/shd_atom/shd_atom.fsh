varying vec3 norm;

uniform vec3 color;

void main() {
    vec3 light = normalize(vec3(1, 1, 2));
    gl_FragColor = vec4(color * max(dot(norm, light), 0.6), 1);
}