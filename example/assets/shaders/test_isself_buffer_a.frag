#include <common/common_header.frag>


uniform float R;
uniform float G;
uniform float B;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec4 col;
    float radius = 50.;
    
    float dist = distance(iMouse.xy, fragCoord);
    col = vec4(0., 0., 0., 0.);
    if (dist < radius) 
        col = vec4(R * abs(sin(iTime)), G * abs(sin(iTime)), B * abs(sin(iTime)), 1.);
    
    // vec2 from = uv-vec2(sin(iTime) * 0.1, cos(iTime) * 0.1);
    // vec4 col2 = texture(iChannel0, from) * 0.8;
    
    // fragColor = col + col2;
    fragColor = col;
}



#include <common/main_shadertoy.frag>

