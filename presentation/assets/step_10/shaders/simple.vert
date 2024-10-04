#version 460 core

in vec3 position;
in vec3 color;

out vec3 vertex_color;

uniform VertInfo {
  mat4 model;
  mat4 view;
  mat4 projection;
};

void main() {
  gl_Position = projection * view * model * vec4(position, 1.0);
  vertex_color = color;
}
