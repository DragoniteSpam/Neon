varying vec3 norm;

void main() {
    vec3 light = normalize(vec3(-1));
    vec3 color = vec3(1, 0, 0);
    float NdotL = -dot(norm, light);
    gl_FragColor = vec4(color * max(NdotL, 0.25), 1);
}