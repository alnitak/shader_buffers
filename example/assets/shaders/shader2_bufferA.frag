#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

layout(location = 0) uniform sampler2D iChannel0;
layout(location = 1) uniform vec2 iResolution;
layout(location = 2) uniform float iTime;
layout(location = 3) uniform float iFrame;
layout(location = 4) uniform vec4 iMouse;

out vec4 fragColor;




#define A(u) texture(iChannel0,(u)/iResolution.xy)
void mainImage( out vec4 fragColor, in vec2 u )
{
    vec2 v = u/iResolution.xy;
    vec4 a = A(u);
    vec2 m = +a.xy                      //fluid velocity
             -vec2(0,1)*.01             //gravity
             +float(v.x<.05)*vec2(1,0)  //wall
             +float(v.y<.05)*vec2(0,1)  //wall
             -float(v.x>.95)*vec2(1,0)  //wall
             -float(v.y>.95)*vec2(0,1); //wall
    float s = 0.;
    // float z = 4.;//kernel convolution size
    for(float i=-4.; i<=4.; ++i){
    for(float j=-4.; j<=4.; ++j){
      vec2 c = -m+vec2(i,j);//translate the gaussian 2Dimage using the velocity
      s += exp(-dot(c,c));  //calculate the gaussian 2Dimage
    }}
    if(s==0.){s = 1.;}      //avoid division by zero
              s = 1./s;
    fragColor = vec4(m,s,0);//velocity in .xy
                            //convolution normalization in .z
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