#include <common/common_header.frag>

uniform sampler2D iChannel0;



// ------ START SHADERTOY CODE -----

// credits:
// https://www.shadertoy.com/view/mldcD2


#define PI 3.14159

#define COLUMNS 19
#define ROWS 10

#define OFFSET vec2(3, 2)
#define ITERATIONS 5

#define GLOW 0.6


float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}


float worley(vec2 position) {
    vec2 cell = floor(position * vec2(COLUMNS, ROWS));
    
    float min_dist = 1000.0;
    
    for (int y = -2; y < 3; y++) {
        for (int x = -2; x < 3; x++) {
            vec2 i = cell + vec2(x, y);
            
            float angle = rand(i) * 2.0 * PI + iTime;
            
            vec2 center = vec2(cos(angle), sin(angle)) * 0.4;
            
            vec2 transform = center + i;
            
            float d = distance(position * vec2(COLUMNS, ROWS), transform);
            
            min_dist = min(min_dist, d);
        }
    }
    
    return 1.0 - min_dist;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    
    vec2 offset = vec2(0, 0);
    
    for (int i = 0; i < ITERATIONS; i++) {
        float noise = worley(uv + offset);
        offset += noise * OFFSET / iResolution.xy;
    }
    
    vec4 col = texture(iChannel0, uv + offset);
    
    float glow = GLOW * (1.0 - worley(uv + offset));
    
    fragColor = mix(col, vec4(1), glow);
}
// ------ END SHADERTOY CODE -----



#include <common/main_shadertoy.frag>