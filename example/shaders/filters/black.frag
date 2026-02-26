// credits:
// https://github.com/PixiColorEffects/pixi-color-effects/blob/main/src/filters/black/fragment.frag

// including this is mandatory since the [LayerBuffer] always
// set the uniforms defined in common_header.frag
#include <../common/common_header.frag>

// this is already defined in the common_header.frag
// precision highp float; 

// I think this is manage by PixiColorEffects internally and
// should represend the normalized windows size. 
// Its definition is moved in main()
// varying vec2 vTextureCoord;

uniform sampler2D uSampler;
uniform float value; // this should be in 0-255 range

void main() {

    vec2 vTextureCoord = FlutterFragCoord().xy / iResolution.xy;

    float bval = value / 255.0;
    float wval = (255.0 / (255.0 - value));

    // texture2D is not a SKSL function. Renaming it to "texture"
    // vec3 color = texture2D(uSampler, vTextureCoord).rgb;
    vec3 color = texture(uSampler, vTextureCoord).rgb;
    color = color * wval - (bval *  wval);

    // gl_FragColor is named "fragColor"
    // texture2D is not a SKSL function. Renaming to "texture"
    // gl_FragColor = vec4(color, texture2D(uSampler, vTextureCoord).a);
    fragColor = vec4(color, texture(uSampler, vTextureCoord).a);
}
