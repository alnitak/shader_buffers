#include <common/common_header.frag>

uniform sampler2D iChannel0;



// ------ START SHADERTOY CODE -----
// basic feedback mechanism by Xavierseb
void mainImage( out vec4 fragColor, in vec2 fragCoord ){    

    vec2 mouse = iMouse.xy;
    // if mouse not detected do something
    if(mouse.x <= 0.) mouse = vec2( iResolution.x * (sin(iTime)+1.)/2., iResolution.y/2.);
    
    // diameter of blob and intensity in same formula because why not
    vec3 blob = vec3(.10-clamp(length((fragCoord.xy-mouse.xy)/iResolution.x),0.,.11));
 
    vec3 stack= texture(iChannel0,fragCoord.xy/iResolution.xy).xyz * vec3(0.99,.982,.93);
    
    fragColor = vec4(stack + blob, 1.0);
}
// ------ END SHADERTOY CODE -----



#include <common/main_shadertoy.frag>