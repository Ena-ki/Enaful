#version 460 compatibility

#include "shaderValues.h"

in vec2 uv;
uniform sampler2D colortex0;

#define DITHER_SIZE 4.0 //[1.0 2.0 4.0 8.0 16.0 32.0 64.0 128.0 256.0 512.0]
//#define USE_GRAYSCALE
//#define USE_CUSTOM_COLORS

uniform float viewHeight;
uniform float viewWidth;

const mat4x4 threshold = mat4x4
(0.5, 8., 2., 10., 
12., 4., 14., 6.,
3.,11.,1.,9.,
15,7.,13., 5.);


vec3 findClosestVec(int x, int y, float v)
{
    mat4x4 thresholdT = transpose(threshold);
    float t = (thresholdT[x][y]) / 16.; //t is constant , only v varies
    if(t > v*6.0){
        return vec3(CUSTOM_COLOR1_R,CUSTOM_COLOR1_G,CUSTOM_COLOR1_B);
    }
    else if(t > v*1.75){
        return vec3(CUSTOM_COLOR2_R,CUSTOM_COLOR2_G,CUSTOM_COLOR2_B);
    }
    else if(t > v * 0.95){
        return vec3(CUSTOM_COLOR3_R,CUSTOM_COLOR3_G,CUSTOM_COLOR3_B);
    }
    else{
        return vec3(CUSTOM_COLOR4_R,CUSTOM_COLOR4_G,CUSTOM_COLOR4_B);
    }
    
}

float findClosestFloat(int x, int y, float v)
{
    mat4x4 thresholdT = transpose(threshold);
    float t = (thresholdT[x][y]) / 16.;
    if(t > v*16.0){
        return v * 0.25;
    }
    else if(t > v*4.0){
        return v * 0.5;
    }
    else if(t >= v){
        return v * 0.75;
    }
    else{
        return v;
    } // Quantize this shit
        // still looks kinda shit (grid) 
    
}

// make it so that if a pixel is a certain amount of length away from center it gets bigger
void main()
{   float uv2 = length(gl_FragCoord.xy/ivec2(viewWidth,viewHeight) - vec2(0.5));
    float dither = DITHER_SIZE;
    #ifdef BOTTLE
    dither *= uv2 * 92.0;
    #endif
    vec2 uv1 = (gl_FragCoord.xy - vec2(int(gl_FragCoord.x) % int(dither), int(gl_FragCoord.y) % int(dither)))/ivec2(viewWidth,viewHeight); //sets uv1 to 0-1
    vec4 col = texture(colortex0, uv1); // gives us the texture

   	int x = int(gl_FragCoord.x / dither) % 4; // gives us the 1 - 4 pixel coords
    int y = int(gl_FragCoord.y / dither) % 4;
    
	float lum = dot(vec3(0.2126, 0.7152, 0.0722), col.rgb); // average color of a pixel
    
    if (lum > 0.5){
        lum = 1 - (1-lum) * (1-lum) * 2;
    }
    else{
        lum *= lum * 2;
    }
    #ifdef USE_CUSTOM_COLORS
        gl_FragColor = vec4(findClosestVec(x ,y, lum),1.0);
    #else
        #ifdef USE_GRAYSCALE 
            gl_FragColor = vec4(vec3(findClosestFloat(x,y,lum)),1.0);
        #else
	        gl_FragColor = vec4(findClosestFloat(x,y,col.r),findClosestFloat(x,y,col.g),findClosestFloat(x,y,col.b),1.0);
        #endif
    #endif
}