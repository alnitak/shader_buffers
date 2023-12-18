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
// https://www.shadertoy.com/view/DdtBRB






void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = vec2(uv.x, 1. - uv.y);
    
    vec4 t = texture(iChannel0, uv);
    
    vec2 mouseCoord = vec2(iMouse.x, iResolution.y - 1. - iMouse.y);
    
    fragColor = t;
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