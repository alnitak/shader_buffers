#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

uniform sampler2D iChannel0;
uniform vec2 iResolution;
uniform float iTime;
uniform float iFrame;
uniform vec4 iMouse;

out vec4 fragColor;



// basic feedback mechanism by Xavierseb
void mainImage( out vec4 fragColor, in vec2 fragCoord ){    

    vec2 mouse = iMouse.xy;
    // if mouse not detected do something
    if(mouse.x <= 0.) mouse = vec2( iResolution.x * (sin(iTime)+1.)/2., iResolution.y/2.);
    
    // diameter of blob and intensity in same formula because why not
    vec3 blob = vec3(.10-clamp(length((fragCoord.xy-mouse.xy)/iResolution.x),0.,.11));
 
    vec3 stack= texture(iChannel0,fragCoord.xy/iResolution.xy).xyz * vec3(0.99,.982,.93);
    
    fragColor = vec4(stack + blob, 1.0);
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