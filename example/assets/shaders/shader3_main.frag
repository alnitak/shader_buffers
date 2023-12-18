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
// https://www.shadertoy.com/view/Xsc3DB


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = texture(iChannel0, uv).xy-.5;
    p = abs(p*2.);
	fragColor = vec4(p.x,p.y,length(p),1.);
}


void main() {
    // Shader compiler optimizations will remove unusued uniforms.
    // Since [LayerBuffer.computeLayer] needs to always set these uniforms, when 
    // this happens, an error occurs when calling setFloat()
    // `IndexError (RangeError (index): Index out of range: index should be less than 3: 3)`
    // With the following line, the compiler will not remove unusued
    float tmp = (iFrame/iFrame) * (iMouse.x/iMouse.x) * 
        (iTime/iTime) * (iResolution.x/iResolution.x);
    if (tmp != 1.) tmp = 1.;

    mainImage( fragColor, FlutterFragCoord().xy * tmp );
}