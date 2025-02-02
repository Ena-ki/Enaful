#version 460

uniform sampler2D gtexture;
uniform sampler2D lightmap;

in vec2 texCoord;
in vec4 vaColor;
in vec3 folliageColor;
in vec2 lightMapCoords;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

void main() {
  vec3 lightColor = pow(texture(lightmap,lightMapCoords).rgb,vec3(2.2));

  vec4 outputColorData = pow(texture(gtexture , texCoord),vec4(2.2));
  vec3 outputColor  = outputColorData.rgb * pow(folliageColor,vec3(2.2)) * lightColor;
  if (outputColorData.a < .1){
    discard;
  }
  outColor0 = pow(vec4(outputColor, outputColorData.a),vec4(1/2.2));
}