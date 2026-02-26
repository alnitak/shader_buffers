#include <common/common_header.frag>

uniform sampler2D iChannel0;
uniform sampler2D iChannel1;


// credits:
// https://www.shadertoy.com/view/MstBzf

// ------ START SHADERTOY CODE -----
float seed = 16.0;
float sinNoise(vec2 uv)
{
    return fract(abs(sin(uv.x * 180.0 + uv.y * 3077.0) * 53703.27));
}

float valueNoise(vec2 uv, float scale)
{
    vec2 luv = fract(uv * scale);
    vec2 luvs = smoothstep(0.0, 1.0, fract(uv * scale));
    vec2 id = floor(uv * scale);
    float tl = sinNoise(id + vec2(0.0, 1.0));
    float tr = sinNoise(id + vec2(1.0, 1.0));
    float t = mix(tl, tr, luvs.x);

    float bl = sinNoise(id + vec2(0.0, 0.0));
    float br = sinNoise(id + vec2(1.0, 0.0));
    float b = mix(bl, br, luvs.x);

    return mix(b, t, luvs.y) * 2.0 - 1.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

//    uv.y /= iResolution.x/iResolution.y;

    float sinN = sinNoise(uv);

    float scale = 4.0;

    float fractValue = 0.0;
    float amp = 1.0;
    for(int i = 0; i < 16; i++)
    {
        fractValue += valueNoise(uv, float(i + 1) * scale) * amp;
        amp /= 2.0;
    }

    fractValue /= 2.0;
    fractValue += 0.5;

    float time = mix(-0.5, 1.0, cos(iTime)/2.0 +0.5);
    //time = 1.0;
    float cutoff = smoothstep(time+ 0.1, time- 0.1, fractValue);

    vec4 col = mix(texture(iChannel1, uv), texture(iChannel0, uv), cutoff);

    // Output to screen
    fragColor = vec4(col);
}
// ------ END SHADERTOY CODE -----



#include <common/main_shadertoy.frag>