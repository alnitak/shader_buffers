#version 460 core
precision mediump float;
#include <flutter/runtime_effect.glsl>

uniform sampler2D iChannel0;
uniform vec2 uResolution;
uniform float iTime;
uniform float iFrame;
uniform vec4 iMouse;

out vec4 fragColor;
vec3 iResolution;

// https://www.shadertoy.com/view/4lySDc



vec2 lighting(vec2 uv)
{
    // vec2 tx1 = 1.0 / iResolution.xy;
    vec2 tx1 = vec2(3.0, 3.0);
    vec4 nx0 = texture(iChannel0, uv + vec2(-tx1.x, 0));
    vec4 nx1 = texture(iChannel0, uv + vec2(tx1.x, 0));
    vec4 ny0 = texture(iChannel0, uv + vec2(0, -tx1.y));
    vec4 ny1 = texture(iChannel0, uv + vec2(0, tx1.y));
    
    float ax0 = nx0.y + nx0.w;
    float ax1 = nx1.y + nx1.w;
    float ay0 = ny0.y + ny0.w;
    float ay1 = ny1.y + ny1.w;
    
    vec3 tx = vec3(0.35, 0.0, ax0 - ax1);
    vec3 ty = vec3(0.0, 0.35, ay0 - ay1);
    vec3 N = normalize(cross(tx, ty));
    
    vec3 L = normalize(vec3(1.0, 1.0, 2.0));
    
    float diff = max(dot(N, L) * 0.65 + 0.35, 0.0);
    float spec = clamp(dot(reflect(L, N),vec3(0., 0., -1.)), 0.0, 1.0);
    spec = pow(spec, 12.0);
    
    return vec2(diff, spec);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 mat = texture(iChannel0, uv);
    
    vec3 color0 = vec3(1.0, 1.0, 0.0);
    vec3 color1 = vec3(0.0, 0.0, 0.0);
    
    // normalize material density
    float matTotal = mat.y + mat.w;
    if (matTotal > 1.0)
    	mat.yw /= matTotal;
    
    vec3 matColor = color0 * mat.y + color1 * mat.w;
    vec2 light = lighting(uv);
    vec3 finalColor = matColor * light.x + light.y;
    
	fragColor = vec4(finalColor, 1.0);
}






void main() {
    iResolution = vec3(uResolution.x, uResolution.y, 0.);

    mainImage( fragColor, FlutterFragCoord().xy );
}