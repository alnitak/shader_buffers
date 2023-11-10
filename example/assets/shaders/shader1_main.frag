#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

uniform sampler2D iChannel0;
uniform vec2 iResolution;
uniform float iTime;
uniform float iFrame;
uniform vec4 iMouse;

out vec4 fragColor;

// credits:
// https://www.shadertoy.com/view/WlsGRM

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	fragColor = vec4(texture(iChannel0,fragCoord.xy/iResolution.xy).xyz,1.0);
}


void main() {
    // Shader compiler optimizations will remove unusued uniforms.
    // Since [LayerBuffer.computeLayer] needs to always set these uniforms, when 
    // this happens, an error occurs when calling setFloat()
    // `IndexError (RangeError (index): Index out of range: index should be less than 3: 3)`
    // With the following line, the compiler will not remove unusued
    float tmp = (iFrame/iFrame) * (iMouse.x/iMouse.x) * 
        (iTime/iTime) * (iResolution.x/iResolution.x);

    mainImage( fragColor, FlutterFragCoord().xy * tmp );
}