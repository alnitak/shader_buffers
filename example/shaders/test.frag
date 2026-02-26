#include <common/common_header.frag>



// credits:
// https://www.shadertoy.com/view/MttGz7
// https://inspirnathan.com/posts/53-shadertoy-tutorial-part-7/ @method #3

// ------ START SHADERTOY CODE -----
// Fork of "zpm test raymarching" by zpm. https://shadertoy.com/view/MclSzX
// 2024-01-20 08:41:14

// https://inspirnathan.com/posts/53-shadertoy-tutorial-part-7/ @method #3

#define MAX_MARCHING_STEPS 85.
#define MIN_DIST 0.0
#define MAX_DIST 60.0
#define PRECISION 0.0001
#define EPSILON 0.0001
#define DISTANCE_BIAS 0.7
#define PI 3.14159265359

#define COLOR_BACKGROUND vec3(0., 0., 0.)
#define COLOR_AMBIENT vec3(0.1, 0.1, 0.1)

#define MAT_RED vec3(1.,0.,0.)
#define MAT_1 vec3(0.443,0.725,0.953)
#define MAT_2 vec3(0.353,0.671,0.980)
#define MAT_3 vec3(0.208,0.278,0.627)
#define MAT_4 vec3(1. + 0.7*mod(floor(p.x) + floor(p.z), 2.0))


float dot2( in vec3 v ) { return dot(v,v); }



float sdPlane(vec3 p)
{
    return p.y;
}

float sdSphere(vec3 p, float r, vec3 offset)
{
    return length(p - offset) - r;
}

// Distance from p to box whose half-dimensions are b.x, b.y, b.z
float sdBox( vec3 p, vec3 b )
{
    vec3 d = abs(p) - b;
    return min( max(d.x,max(d.y,d.z) ),0.0) + length(max(d,0.0));
}

// Distance from p to box of half-dimensions b.x,y,z plus buffer radius r
float udRoundBox( vec3 p, vec3 b, float r)
{
    return length( max(abs(p)-b,0.0) )-r;
}

float udTriangle( in vec3 v1, in vec3 v2, in vec3 v3, in vec3 p )
{
    vec3 v21 = v2 - v1; vec3 p1 = p - v1;
    vec3 v32 = v3 - v2; vec3 p2 = p - v2;
    vec3 v13 = v1 - v3; vec3 p3 = p - v3;
    vec3 nor = cross( v21, v13 );

    return sqrt( (sign(dot(cross(v21,nor),p1)) + 
                  sign(dot(cross(v32,nor),p2)) + 
                  sign(dot(cross(v13,nor),p3))<2.0) 
                  ?
                  min( min( 
                  dot2(v21*clamp(dot(v21,p1)/dot2(v21),0.0,1.0)-p1), 
                  dot2(v32*clamp(dot(v32,p2)/dot2(v32),0.0,1.0)-p2) ), 
                  dot2(v13*clamp(dot(v13,p3)/dot2(v13),0.0,1.0)-p3) )
                  :
                  dot(nor,p1)*dot(nor,p1)/dot2(nor) );
}


///////////////////////
// Matrix
///////////////////////
mat2 rotate2d(float theta) {
  float s = sin(theta), c = cos(theta);
  return mat2(c, -s, s, c);
}

// Rotation matrix around the X axis.
mat3 rotateX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}

// Rotation matrix around the Y axis.
mat3 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}

// Rotation matrix around the Z axis.
mat3 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}

// Identity matrix.
mat3 identity() {
    return mat3(
        vec3(1, 0, 0),
        vec3(0, 1, 0),
        vec3(0, 0, 1)
    );
}


// This function comes from glsl-rotate https://github.com/dmnsgn/glsl-rotate/blob/main/rotation-3d.glsl
mat4 rotation3d(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(
    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
    0.0,                                0.0,                                0.0,                                1.0
  );
}
vec3 rotate(vec3 v, vec3 axis, float angle) {
  mat4 m = rotation3d(axis, angle);
  return (m * vec4(v, 1.0)).xyz;
}



///////////////////////
// Boolean Operators
///////////////////////
vec4 opUnion(vec4 d1, vec4 d2) { 
  return (d1.x < d2.x) ? d1 : d2;
}

float opSmoothUnion(float d1, float d2, float k) {
  float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0., 1. );
  return mix( d2, d1, h ) - k*h*(1.-h);
}

vec4 opSmoothUnion(vec4 d1, vec4 d2, float k ) 
{
  float h = clamp(0.5 + 0.5*(d1.x-d2.x)/k, 0., 1.);
  vec3 c = mix(d1.yzw, d2.yzw,h);
  float d = mix(d1.x, d2.x, h) - k*h*(1.-h); 
   
  return vec4(d, c);
}



vec4 opIntersection(vec4 d1, vec4 d2) {
  return (d1.x > d2.x) ? d1 : d2;
}

float opSmoothIntersection(float d1, float d2, float k) {
  float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
  return mix( d2, d1, h ) + k*h*(1.0-h);
}

vec4 opSmoothIntersection(vec4 d1, vec4 d2, float k ) 
{
  float h = clamp(0.5 - 0.5*(d1.x-d2.x)/k, 0., 1.);
  vec3 c = mix(d1.yzw, d2.yzw, h);
  float d = mix(d1.x, d2.x, h) + k*h*(1.-h);
   
  return vec4(d, c);
}



vec4 opSubtraction(vec4 d1, vec4 d2) {
  return d1.x > -d2.x ? d1 : vec4(-d2.x, d2.yzw);
}

float opSmoothSubtraction(float d1, float d2, float k) {
  float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
  return mix( d2, -d1, h ) + k*h*(1.0-h);
}
 
vec4 opSmoothSubtraction(vec4 d1, vec4 d2, float k) 
{
  float h = clamp(0.5 - 0.5*(d1.x+d2.x)/k, 0., 1.);
  vec3 c = mix(d1.yzw, d2.yzw, h);
  float d = mix(d1.x, -d2.x, h ) + k*h*(1.-h);
   
  return vec4(d, c);
}



float opExtrusion(in vec3 p, in float sdf, in float h) {
  vec2 w = vec2(sdf, abs(p.z) - h);
  return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}



vec4 sdFlutterLogoUncut(vec3 p) {
    
    p = rotate(p, vec3(0.0, 0.0, 1.0), -PI/4.);
    
    vec4 roundedBox1 = vec4(
        udRoundBox(p+vec3(1.8, -2., 0.), vec3(.3, 1.5, 0.3), 0.05), 
        MAT_1);
    vec4 roundedBox2 = vec4(
        udRoundBox(p+vec3(0.71, -1.52, 0.), vec3(.3, 1., 0.3), 0.05), 
        MAT_1);
    vec4 roundedBox3 = vec4(
        udRoundBox(p+vec3(0.01, -0.8, 0.01), vec3(1., .3, 0.33), 0.05), 
        MAT_3);
      
    vec4 res = opUnion(roundedBox1, roundedBox2);
    res = opUnion(res, roundedBox3);
    return res;
}


vec4 sdFlutterLogo(vec3 p) {
    p = rotate(p, vec3(0., 1., 0.), iTime/10.) + vec3(1., sin(iTime)+.5, 0.);
    
    vec3 s = vec3(8., 0., 5.);
    vec3 id = round(p/s);
    p = p - s*id;
    
    vec4 box1 = vec4(
        sdBox(p+vec3(-1.1, -3.8, 0.), vec3(.6, .3, 0.5)), 
        MAT_1);
    vec4 box2 = vec4(
        sdBox(p+vec3(-1.12, -2.28, 0.), vec3(.6, .25, 0.5)), 
        MAT_1);
    vec4 box3 = vec4(
        sdBox(p+vec3(-1.1, .2, 0.), vec3(.6, .25, 0.5)), 
        MAT_3);
    vec4 flutterUncut = sdFlutterLogoUncut(p);
      
    vec4 res = opUnion(box1, box2);
    res = opUnion(res, box3);
    res = opSmoothSubtraction(flutterUncut, res, 0.1);
    return res;
}

vec4 scene(vec3 p) {

  vec4 center = vec4(sdSphere(p, .2, vec3(0., 0., 0.)), MAT_RED);
  vec4 plane = vec4(sdPlane(p), MAT_4);

  vec3 p1 = rotate(p, vec3(0., 1., 0.), iTime/4.) + 
      vec3(1., sin(iTime)*2.+1.3 , 0.);
  vec4 flutterLogo = sdFlutterLogo(p);
  
  vec4 res = opUnion(center, plane);
  res = opSmoothUnion(res, flutterLogo, 0.3);
  return res;
}

vec4 rayMarch(vec3 ro, vec3 rd) {
  float depth = MIN_DIST;
  vec4 d; // .yzw color   .x distance ray has travelled

  for (float i = 0.; i < MAX_MARCHING_STEPS; i++) {
    vec3 p = ro + depth * rd;
    d = scene(p);
    depth += d.x * DISTANCE_BIAS;
    if (d.x < PRECISION || depth > MAX_DIST) break;
  }
  
  d.x = depth;
  
  return d;
}

vec3 calcNormal(in vec3 p) {
    vec2 e = vec2(1, -1) * EPSILON;
    return normalize(
      e.xyy * scene(p + e.xyy).x +
      e.yyx * scene(p + e.yyx).x +
      e.yxy * scene(p + e.yxy).x +
      e.xxx * scene(p + e.xxx).x);
}

mat3 camera(vec3 cameraPos, vec3 lookAtPoint) {
	vec3 cd = normalize(lookAtPoint - cameraPos);
	vec3 cr = normalize(cross(vec3(0, 1, 0), cd));
	vec3 cu = normalize(cross(cd, cr));
	
	return mat3(-cr, cu, -cd);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
  vec2 mouseUV = iMouse.xy/iResolution.xy;
  uv = vec2(uv.x, 1. - uv.y);
  mouseUV = vec2(mouseUV.x, 1. - mouseUV.y);
  
  if (iMouse.xy == vec2(1.0)) 
      mouseUV = vec2(0.6, 0.3); // trick to center mouse on page load

  vec3 col = vec3(0.);
  vec3 lp = vec3(0., -16., 0.);
  vec3 ro = vec3(-15., 3., 2.); // ray origin that represents camera position
  
  float cameraRadius = 2.;
  ro.yz = ro.yz * cameraRadius * rotate2d(mix(-PI/2., PI/2., mouseUV.y));
  ro.xz = ro.xz * rotate2d(mix(-PI, PI, mouseUV.x)) + vec2(lp.x, lp.z);

  vec3 rd = camera(ro, lp) * normalize(vec3(uv, -1.)); // ray direction

  vec4 d = rayMarch(ro, rd); // .yzw color   .x signed distance value to closest object

  if (d.x > MAX_DIST) {
    col = COLOR_BACKGROUND; // ray didn't hit anything
  } else {
    vec3 p = ro + rd * d.x; // point discovered from ray marching
    vec3 normal = calcNormal(p); // surface normal

    vec3 lightPosition = vec3(0., 5., 2.);
    vec3 lightDirection = normalize(lightPosition - p) * .65; // The 0.65 is used to decrease the light intensity a bit

    float dif = clamp(dot(normal, lightDirection), 0., 1.) * 0.5 + 0.5; // diffuse reflection mapped to values between 0.5 and 1.0

    col = dif * d.yzw + COLOR_AMBIENT;
  
  }

  fragColor = vec4(col, 1.0);
}
// ------ END SHADERTOY CODE -----



#include <common/main_shadertoy.frag>