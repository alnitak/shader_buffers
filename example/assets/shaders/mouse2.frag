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
// https://www.shadertoy.com/view/Mss3zH
float distanceToSegment( vec2 a, vec2 b, vec2 p )
{
	vec2 pa = p - a, ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord / iResolution.x;
    vec2 cen = 0.5*iResolution.xy/iResolution.x;
    vec4 m = iMouse / iResolution.x;
	
	vec3 col = vec3(0.0);

	if( m.z>0.0 ) // button is down
	{
		float d = distanceToSegment( m.xy, abs(m.zw), p );
        col = mix( col, vec3(1.0,1.0,0.0), 1.0-smoothstep(.004,0.008, d) );
	}
	if( m.w>0.0 ) // button click
	{
        col = mix( col, vec3(1.0,1.0,1.0), 1.0-smoothstep(0.1,0.105, length(p-cen)) );
    }

	col = mix( col, vec3(1.0,0.0,0.0), 1.0-smoothstep(0.03,0.035, length(p-    m.xy )) );
    col = mix( col, vec3(0.0,0.0,1.0), 1.0-smoothstep(0.03,0.035, length(p-abs(m.zw))) );

	fragColor = vec4( col, 1.0 );
}


void main() {
    iResolution = vec3(uResolution.x, uResolution.y, 0.);

    mainImage( fragColor, FlutterFragCoord().xy );
}