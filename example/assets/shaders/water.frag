#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

uniform sampler2D iChannel0;
uniform vec2 iResolution;
uniform float iTime;
uniform float iFrame;
uniform vec4 iMouse;

uniform float speed;     // 0.6
uniform float frequency; // 8.0
uniform float amplitude; // 1.0

out vec4 fragColor;

// credits:
// https://www.shadertoy.com/view/Mls3DH


// [2TC 15] Water2D
// Copyleft {c} 2015 Michael Pohoreski
// Chars: 260
//
// Notes:
// - If you want to speed up / slow this down, change the contant in `d` iTime*0.2
//
// - A "naive" water filter is: 
//     #define F cos(x)*cos(y),sin(x)*sin(y)
//   We use this one:
//     #define F cos(x-y)*cos(y),sin(x+y)*sin(y)
// Feel free to post your suggestions!
//
// For uber minification,
// - You can replace:
//     2.0 / uvResolution.x
//   With say a hard-coded constant:
//     0.007
// Inline the #define

// Minified

#if 0

#define F cos(x-y)*cos(y),sin(x+y)*sin(y)
vec2 s(vec2 p){float d=iTime*0.2,x=8.*(p.x+d),y=8.*(p.y+d);return vec2(F);}
void mainImage( out vec4 f, in vec2 w ){vec2 i=iResolution.xy,r=w/i,q=r+2./iResolution.x*(s(r)-s(r+i));q.y=1.-q.y;f=texture(iChannel0,q);}


#else
// Cleaned up Source

vec2 shift( vec2 p ) {                        
    float d = iTime*speed;
    vec2 f = frequency * (p + d);
    vec2 q = cos( vec2(                        
       cos(f.x-f.y)*cos(f.y),                       
       sin(f.x+f.y)*sin(f.y) ) );                   
    return q;                                  
}                                             

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {                                 
    vec2 r = fragCoord.xy / iResolution.xy;                      
    vec2 p = shift( r );             
    vec2 q = shift(r + 1.0);                        
    float amp = amplitude * 60.0 / iResolution.x;   
    vec2 s = r + amp * (p - q);
    s.y = 1. - s.y; // flip Y axis for ShaderToy
    fragColor = texture( iChannel0, s );
}
#endif 




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