#version 460 core

in vec2 position;
in vec2 uv;

out vec2 vertex_uv;

uniform VertInfo {
  mat4 model;
  mat4 view;
  mat4 projection;
};

void main() {
  gl_Position = projection * view * model * vec4(position, 0.0, 1.0);
  vertex_uv = uv;
}