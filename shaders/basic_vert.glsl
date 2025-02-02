#version 460

in vec3 vaPosition;
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;

out vec2 texCoord;
out vec3 folliageColor;
out vec2 lightMapCoords;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 chunkOffset;



void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vec4(chunkOffset + vaPosition ,1);

  lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);
  folliageColor = vaColor.rgb;
  texCoord = vaUV0;
}