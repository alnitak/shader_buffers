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
// https://www.shadertoy.com/view/sl3Szs



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 u = fragCoord/iResolution.xy;
    u = vec2(u.x, 1. - u.y);
    vec4 a = texture(iChannel0,u);
    fragColor = a.z*(+sin(a.x*4.+vec4(1,3,5,4))*.2
                     +sin(a.y*4.+vec4(1,3,2,4))*.2+.6);
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