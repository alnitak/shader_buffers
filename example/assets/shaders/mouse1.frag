#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

layout(location = 1) uniform vec2 uResolution;
layout(location = 2) uniform float iTime;
layout(location = 3) uniform float iFrame;
layout(location = 4) uniform vec4 iMouse;

out vec4 fragColor;
vec3 iResolution;


// credits:
// https://www.shadertoy.com/view/XlyBzt
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 col = vec3(0.);

    //Draw a red cross where the mouse button was last down.
    if(abs(iMouse.x-fragCoord.x) < 4.) {
        col = vec3(1.,0.,0.);
    }
    if(abs(iMouse.y-fragCoord.y) < 4.) {
        col = vec3(1.,0.,0.);
    }
    
    //If the button is currently up, (iMouse.z, iMouse.w) is where the mouse
    //was when the button last went down.
    if(abs(iMouse.z-fragCoord.x) < 2.) {
        col = vec3(0.,0.,1.);
    }
    if(abs(iMouse.w-fragCoord.y) < 2.) {
        col = vec3(0.,0.,1.);
    }
    
    //If the button is currently down, (-iMouse.z, -iMouse.w) is where
    //the button was when the click occurred.
    if(abs(-iMouse.z-fragCoord.x) < 2.) {
        col = vec3(0.,1.,0.);
    }
    if(abs(-iMouse.w-fragCoord.y) < 2.) {
        col = vec3(0.,1.,0.);
    }
    
    fragColor = vec4(col, 1.0);
}



void main() {
    iResolution = vec3(uResolution.x, uResolution.y, 0.);

    mainImage( fragColor, FlutterFragCoord().xy );
}