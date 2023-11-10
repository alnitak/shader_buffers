#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform vec2 iResolution;
uniform float iTime;
uniform float iFrame;
uniform vec4 iMouse;

out vec4 fragColor;




//Ethan Shulman 2016
#define AUTO_CURSOR

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iFrame < 60) {
        fragColor = texture(iChannel1, fragCoord/iResolution.xy);
        return;
    }
    
    vec2 uv = fragCoord.xy/iResolution.xy;
    #ifdef AUTO_CURSOR
    if (iMouse.z < 1.) {
        if (iTime > 10. && sin(iTime*.2) > -.2) {
            if (length(vec2(sin(iTime*.44)*.8,cos(iTime*.16)*.8)-uv*2.+1.) < .1) {
                fragColor = vec4((normalize(uv-.5)*-.5)*.5+.5,0.,0.);
            	return;
            }
        }
    } else {
        #endif
        if (iMouse.z > 0. && length(iMouse.xy/iResolution.xy-uv) < .05) {

            //if (iMouse.z > 1.5) {
                fragColor = vec4((-normalize(iMouse.xy/iResolution.xy-uv))*.5+.5,0.,0.);
            //} else {
            //	fragColor = vec4((normalize(uv-.5)*-.5)*.5+.5,0.,0.);
            //}
            return;
        }
        #ifdef AUTO_CURSOR
    }
    #endif
    vec2 odRes = 1./iResolution.xy;
        
	vec4 cLeft = texture(iChannel0, fract(uv-vec2(odRes.x,0.)))*2.-1.,
         cRight = texture(iChannel0, fract(uv+vec2(odRes.x,0.)))*2.-1.,
         cUp = texture(iChannel0, fract(uv-vec2(0.,odRes.y)))*2.-1.,
         cDown = texture(iChannel0, fract(uv+vec2(0.,odRes.y)))*2.-1.,
         cTopLeft = texture(iChannel0,fract(uv+vec2(-odRes.x,-odRes.y)))*2.-1.,
         cTopRight = texture(iChannel0,fract(uv+vec2(odRes.x,-odRes.y)))*2.-1.,
         cBottomLeft = texture(iChannel0,fract(uv+vec2(-odRes.x,odRes.y)))*2.-1.,
         cBottomRight = texture(iChannel0,fract(uv+vec2(odRes.x,odRes.y)))*2.-1.;
    
    vec4 c = vec4(0.);
    c += cLeft*(1.+dot(vec2(1.,0.),cLeft.xy));
    c += cRight*(1.+dot(vec2(-1.,0.),cRight.xy));
    c += cUp*(1.+dot(vec2(0.,1.),cUp.xy));
    c += cDown*(1.+dot(vec2(0.,-1.),cDown.xy));
    c += cTopLeft*(1.+dot(normalize(vec2(1.,1.)),cTopLeft.xy));
    c += cTopRight*(1.+dot(normalize(vec2(-1.,1.)),cTopRight.xy));
    c += cBottomLeft*(1.+dot(normalize(vec2(1.,-1.)),cBottomLeft.xy));
    c += cBottomRight*(1.+dot(normalize(vec2(-1.,-1.)),cBottomRight.xy));
    c *= .125;

    c.xy = clamp(c.xy, -1., 1.);
    c = c*.5+.5;
    
    fragColor = c;
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