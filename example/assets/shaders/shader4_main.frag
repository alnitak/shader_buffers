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
    iResolution = vec3(uResolution.x, uResolution.y, 0.);

    mainImage( fragColor, FlutterFragCoord().xy );
}