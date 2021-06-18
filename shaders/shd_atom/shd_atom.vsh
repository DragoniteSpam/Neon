attribute vec3 in_Position;

varying vec3 norm;

void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
    norm = normalize(in_Position);
}