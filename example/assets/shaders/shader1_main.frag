#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

uniform sampler2D iChannel0;
uniform vec2 uResolution;
uniform float iTime;
uniform float iFrame;
uniform vec4 iMouse;

out vec4 fragColor;
vec3 iResolution;

// credits:
// https://www.shadertoy.com/view/WlsGRM

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	fragColor = vec4(texture(iChannel0,fragCoord.xy/iResolution.xy).xyz,1.0);
}


void main() {
    iResolution = vec3(uResolution.x, uResolution.y, 0.);

    mainImage( fragColor, FlutterFragCoord().xy );
}