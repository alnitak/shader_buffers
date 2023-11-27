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
// https://www.shadertoy.com/view/4djGzz

// ------ START SHADERTOY CODE -----
// MTAT.03.015 Computer Graphics
// https://courses.cs.ut.ee/2013/cg/
//
// Basic ripple effect example


// Params = (wave frequency in Hz, number of waves per unit distance)
//
vec2 params = vec2(2.5, 10.0);

// Simple circular wave function
float wave(vec2 pos, float t, float freq, float numWaves, vec2 center) {
    float d = length(pos - center);
    d = log(1.0 + exp(d));
    return 1.0/(1.0+20.0*d*d) *
    sin(2.0*3.1415*(-numWaves*d + t*freq));
}

// This height map combines a couple of waves
float height(vec2 pos, float t) {
    float w;
    w =  wave(pos, t, params.x, params.y, vec2(0.5, -0.5));
    w += wave(pos, t, params.x, params.y, -vec2(0.5, -0.5));
    return w;
}

// Discrete differentiation
vec2 normal(vec2 pos, float t) {
    return 	vec2(height(pos - vec2(0.01, 0), t) - height(pos, t),
                   height(pos - vec2(0, 0.01), t) - height(pos, t));
}

// Simple ripple effect
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    if (iMouse.z > 0.0) params = 2.0*params*iMouse.xy/iResolution.xy;
    else params = vec2(2.5, 10.0);

    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 uvn = 2.0*uv - vec2(1.0);
    uv += normal(uvn, iTime);
    fragColor = texture(iChannel0, vec2(1.0-uv.x, uv.y));
}
// ------ END SHADERTOY CODE -----



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