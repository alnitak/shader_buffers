#include <common/common_header.frag>

uniform sampler2D iChannel0;



// ------ START SHADERTOY CODE -----
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    vec4 col = texture(iChannel0, uv);
    fragColor = col;
}
// ------ END SHADERTOY CODE -----



#include <common/main_shadertoy.frag>