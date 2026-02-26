#include <common/common_header.frag>

// credits:
// https://www.shadertoy.com/view/Nty3Wm

// ------ START SHADERTOY CODE -----
#define pi 3.14159

float thc(float a, float b) {
    return tanh(a * cos(b)) / tanh(a);
}

// square length
float mlength(vec2 uv) {
    return max(abs(uv.x), abs(uv.y));
}

vec2 rot(vec2 uv, float a) {
    mat2 mat = mat2(cos(a), -sin(a), 
                    sin(a), cos(a));
    return mat * uv;
}

float sdEquilateralTriangle( in vec2 p )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - 1.0;
    p.y = p.y + 1.0/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0, 0.0 );
    return -length(p)*sign(p.y);
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

// draws an arrow (d is used to make it go up + down)
float arrow(vec2 uv, float d) {
    float h = 0.1 + 0.4 * thc(4.,2. * d);
    float d1 = sdEquilateralTriangle(uv-vec2(0.,0.25 - h));
    float s1 = step(d1, -0.5);

    float d2 = sdBox(uv - vec2(0.,-h), vec2(0.05,0.2));
    float s2 = step(d2, 0.);
    
    return max(s1, s2);
}

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-0.5*iResolution.xy)/iResolution.y;
    
    // scale (number of arrows)
    float sc = 10.; 
    vec2 ipos = floor(sc * uv) + 0.5;
    ipos /= sc;
    vec2 fpos = fract(sc * uv) - 0.5;
    
    vec2 p = (iMouse.xy-0.5*iResolution.xy)/iResolution.y;
    
    // moving point
    // p = 0.4 * vec2(iResolution.x/iResolution.y * thc(2., 0.5 * iTime), sin(iTime));
     
    // cursor
    float d2 = length(uv-p);
    float s2 = step(d2,0.02) - step(d2,0.016);
    s2 *= 0.5;
    
    // grid
    float d3 = mlength(fpos);
    float s3 = step(d3,0.5) - step(d3,0.48);
    s3 *= 0.2;
    
    // change me!
    float n = 1.;  
    // n = -3.;
    
    // rotate arrows towards cursor
    float th = -0.5 * pi + n * atan(p.y-ipos.y, p.x-ipos.x);
    fpos = rot(fpos, th);
    
    // shrink arrows that are far away
    fpos *= 1. + d2 * d2;  
   
    // arrow
    float s1 = 0.5 * arrow(fpos, d2) ;
    
    float s = max(max(s1,s2), s3);
    
    // fade 
    // s *= pow(1.-length(ipos-p),3.);
    
    vec3 e = vec3(1.);
    vec3 col = s * pal(s3 * th + d2 - 0.4 * iTime, e, e, e, vec3(0.,1., 2.)/3.);
    // col = vec3(s);
    
    fragColor = vec4(col,1.0);
}
// ------ END SHADERTOY CODE -----



#include <common/main_shadertoy.frag>