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



// basic feedback mechanism by Xavierseb
void mainImage( out vec4 fragColor, in vec2 fragCoord ){    

    vec2 mouse = iMouse.xy;
    // if mouse not detected do something
    if(mouse.x <= 0.) mouse = vec2( iResolution.x * (sin(iTime)+1.)/2., iResolution.y/2.);
    
    // diameter of blob and intensity in same formula because why not
    vec3 blob = vec3(.10-clamp(length((fragCoord.xy-mouse.xy)/iResolution.x),0.,.11))*1.;
 
    vec3 stack= texture(iChannel0,fragCoord.xy/iResolution.xy).xyz * vec3(0.99,.982,.93);
    
    fragColor = vec4(stack + blob, 1.0);
}


void main() {
    iResolution = vec3(uResolution.x, uResolution.y, 0.);

    mainImage( fragColor, FlutterFragCoord().xy );
}