#include <common/common_header.frag>

uniform sampler2D iChannel0;



// credits:
// https://www.shadertoy.com/view/WlsGRM

// ------ START SHADERTOY CODE -----
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	fragColor = vec4(texture(iChannel0,fragCoord.xy/iResolution.xy).xyz,1.0);
}
// ------ END SHADERTOY CODE -----



#include <common/main_shadertoy.frag>