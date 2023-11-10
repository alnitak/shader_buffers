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




#define PAINT_MODE 4
#define MIX_MODE 1

const float mixPercent = 0.1;
const float brushRadius = 10.0;

// IMPORTANT: mixPair must be symmetric: mixPair(a,b) + mixPair(b,a) == 0
#if MIX_MODE == 1
vec2 mixPair(vec2 a, vec2 b)
{
    return (b - a) * mixPercent;
}
#elif MIX_MODE == 2
vec2 mixPair(vec2 a, vec2 b)
{
    vec2 sum = vec2(a.x + a.y, b.x + b.y);    
    float amount = (sum.y - sum.x);
    float totalBig = max(sum.x, sum.y);
    if (totalBig == 0.0)
        return vec2(0.0, 0.0);
        
    vec2 movement;
    if (amount < 0.0)
    {
        movement = amount * a / totalBig; 
    }
    else
    {
        movement = amount * b / totalBig; 
    }

    return movement * mixPercent;
}
#endif

vec2 mixNeighbors(vec2 uv, vec4 center)
{
    // vec2 tx1 = 1.0 / iResolution.xy;
    vec2 tx1 = vec2(2.0, 2.0);
    vec4 nx0 = texture(iChannel0, uv + vec2(-tx1.x, 0));
    vec4 nx1 = texture(iChannel0, uv + vec2(tx1.x, 0));
    vec4 ny0 = texture(iChannel0, uv + vec2(0, -tx1.y));
    vec4 ny1 = texture(iChannel0, uv + vec2(0, tx1.y));
    
    vec2 result = center.yw;
    result += mixPair(center.yw, nx0.yw);
    result += mixPair(center.yw, nx1.yw);
    result += mixPair(center.yw, ny0.yw);
    result += mixPair(center.yw, ny1.yw);
    return result;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 prev = texture(iChannel0, uv);

    prev.yw = mixNeighbors(uv, prev);
    
    float brush = 0.0;
    if (iMouse.z >= 0.0)
    {
    	float d = distance(iMouse.xy, fragCoord.xy);
        d /= brushRadius * 3.0;
        brush = clamp(1.0 - d * d * d * d, -0.0, 1.0);
    }
    
    vec2 mmask = vec2(1.4, 0.02);
    
#if PAINT_MODE == 1
    vec2 amt = prev.yw + mmask * brush;
#elif PAINT_MODE == 2
    vec2 amt = mix(prev.yw, mmask, brush);
#elif PAINT_MODE == 3
    vec2 amt = mix(prev.yw, prev.yw * mmask, brush) + mmask * brush;
#elif PAINT_MODE == 4
    float prevTotal = prev.y + prev.w;
    vec2 newVal = (vec2(prevTotal, prevTotal) + brush) * mmask;
    vec2 amt = mix(prev.yw, newVal, brush);
#endif
    
    fragColor = vec4(0.0, amt.x, 1.0, amt.y/2.);
}








void main() {
    iResolution = vec3(uResolution.x, uResolution.y, 0.);

    mainImage( fragColor, FlutterFragCoord().xy );
}