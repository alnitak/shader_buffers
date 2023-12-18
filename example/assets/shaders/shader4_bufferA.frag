#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

uniform sampler2D iChannel0;
uniform vec2 iResolution;
uniform float iTime;
uniform float iFrame;
uniform vec4 iMouse;

out vec4 fragColor;









#define Get(pos) texture(iChannel0, (fragCoord + pos) / iResolution.xy)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float rand = fract(1e5 * sin(dot(fragCoord, vec2(7.133, 9.1))));
    
    if (iFrame == 0) {
        fragColor = vec4(vec3(float(rand < .1)), 1.0);
    } else {
        float current = Get(vec2(0, 0)).x;
        float v = current;
        
        vec3 bottom = vec3(Get(vec2(-1, -1)).x, Get(vec2(0, -1)).x, Get(vec2(1, -1)).x);
        vec3 top = vec3(Get(vec2(-1, 1)).x, Get(vec2(0, 1)).x, Get(vec2(1, 1)).x);
        vec3 row = vec3(Get(vec2(-1, 0)).x, current, Get(vec2(1, 0)).x);

        if (current > 0.0) {
            if (bottom.y == 0.0) {
                v = 0.0;
            }
        } else {
            if (top.y > 0.0 || (top.z > 0.0 && row.z > 0.0 && bottom.z > 0.0) || (top.x > 0.0 && row.x > 0.0 && bottom.x > 0.0)) {
                v = 1.0;
            }   
        }
        
        vec2 uv = fragCoord.xy / iResolution.xy;
        uv = vec2(uv.x, 1. - uv.y);
            
        if (iMouse.z > 0.5) {
            float dist = length (fragCoord - vec2(iMouse.x, iResolution.y -iMouse.y));
            if (current > 0.0 && dist < 20.0) v = 0.0;
            else if (dist < 20.0) v = 1.0 * float(rand < .5);
        }
       

        fragColor = vec4(vec3(1.0, uv.y, uv.x) * v, 1.0);
    }
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