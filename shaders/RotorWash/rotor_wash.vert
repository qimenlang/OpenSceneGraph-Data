#version 120
varying vec2 v_uv;
varying vec3 v_normal;
uniform float iTime;

const float PI = 3.14159265359;

float hash(vec2 p)
{
    return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);
}

// 返回值范围 [0,1]
float hashNoise(vec2 p)
{
    vec2 i=floor(p);
    vec2 f=fract(p);

    float a=hash(i);
    float b=hash(i+vec2(1,0));
    float c=hash(i+vec2(0,1));
    float d=hash(i+vec2(1,1));

    // 平滑插值曲线
    vec2 u=f*f*(3.0-2.0*f);
    // 双线性插值
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float SprayWave(vec2 uv)
{
    float amp = 0.1; // 波纹振幅 米
    float r = length(uv);
    float a = atan(uv.y, uv.x);

    float t = iTime;

    float noise =
        sin(a * 24.0 + t * 2.0) *
        sin(a * 13.0 - t * 1.5);

    float radial =
        sin(r * 40.0 - t * 6.0);

    float distort =
        sin(a * 12.0 + r * 20.0 + t * 3.0);

    // 随距离衰减,0.1处最强；0.0-0.2范围内衰减
    float highpoint = 0.15;
    // float decl = clamp(1.0-  pow(r - highpoint,2.0)/pow(highpoint,2.0), 0.0, 1.0);
    float decl = clamp(1.0 -  44.4*pow(r - highpoint,2.0), 0.0, 1.0);
    // 随距离衰减
    // decl *= exp(-r*declRatio);
 
    // decl = step(r, 0.2);
    
    float noiseheight = hashNoise(uv*100.0);
    float noisehash = hash(uv);

    float height = decl * (0.6 * radial + 0.4 * noise * distort);

    height = decl * (0.6 * radial + 0.4 * noise);

    // height = decl * radial;

    // height = decl * noise;

    height += noiseheight;

    height *= amp;

    if(height<0.1)
        height = 0.0;
    // height = noisehash;

    height/=2.0;

    return height;
}

//--------------------------------
// gerstner wave
//--------------------------------

float gerstnerIrregular(vec2 uv, vec2 dir, float amp, float len, float speed,float declRatio)
{
    float r = length(uv); 
    // 扭曲uv坐标，改变波形形状
    float twistRatio = 5.0;
    vec2 warp = vec2(sin(uv.x*twistRatio),cos(uv.y*twistRatio  + 10.0));
    float bTwist = step(0.01, r);
    // uv += warp * 0.2*bTwist;

    float k=2.0*PI/len;
    float w=k*speed;

    vec2 delta = uv - vec2(0.0,0.0);

    float angle = atan(delta.y, delta.x); // 方位角，范围 [-PI, PI]    
    // 扰动相位，增加八重对称的旋转效果
    // 八重对称方向因子：在八个方向上为1，其余方向小于1
    // cos(8*angle) 在 angle = 0°,45°,90°,135°,180°,225°,270°,315° 时等于1
    float phaseTwist = 0.5 + 0.5 * sin(7.0 * angle);

    float phase=k*dot(uv,dir)-w*iTime+ phaseTwist *r* 20.0;

    // 两种衰减叠加
    float decl = exp(-r*declRatio);
    // 随距离衰减,0.25处最强；0.0-0.5范围内衰减
    float highpoint = 0.3;
    // decl = clamp(1.0-  pow(r - highpoint,2.0)/pow(highpoint,2.0), 0.0, 1.0);
    decl = clamp(1.0- 25.0*pow(r - highpoint,2.0), 0.0, 1.0);
    // 随距离衰减
    // decl *= exp(-r*declRatio);
    amp *= decl; 
    
    return amp*sin(phase);
}


float vortexRing(vec2 uv){

    float r = length(uv); 

    float ring = 0.0;
    // 1. 简单的同心圆波纹

    // ring = sinWave(uv);

    // 2. 叠加多个偏移的波纹，模拟旋翼下的复杂涡流
    // 振幅、波长、速度
    float amp = 0.1; // 波纹振幅 米
    float len = 0.02;
    float speed = 0.05;
    vec2 uv0 = uv-vec2(0.0,0.0);
    float declRatio = 10.0; // 衰减速率

    // 扭曲uv坐标，改变波形形状
    // vec2 warp = vec2(noise(uv*3.0 + iTime),noise(uv*3.0 + iTime + 10.0));
    // uv0 += warp * 0.03;
    // ring =  gerstner(uv0, normalize(uv0), amp, len, speed*0.8);
    ring =  gerstnerIrregular(uv0, normalize(uv0), amp, len, speed*0.8,declRatio);
    
    return ring;
}

float oceanHeight(vec2 uv)
{
    uv -= 0.5; // 以(0.5,0.5)为中心产生波纹
    float height = 0.0;
    height += SprayWave(uv);
    height += vortexRing(uv);
    return height;
}

// 根据高度图计算法线
vec3 getNormal(vec2 p)
{
    float e=0.002;

    float h=oceanHeight(p);
    float hx=oceanHeight(p+vec2(e,0));
    float hy=oceanHeight(p+vec2(0,e));

    return normalize(vec3(h-hx,e,h-hy));
}


void main()
{
    // Vertex position in main camera Screen space.
    v_uv = gl_MultiTexCoord0.xy;

    vec3 vertexPos = gl_Vertex.xyz;

    vertexPos.z = oceanHeight(v_uv);
    v_normal = getNormal(v_uv);
    // vertexPos.z = sin(v_uv.x * 20.0 - iTime * 5.0)*0.1;

    gl_Position = gl_ModelViewProjectionMatrix * vec4(vertexPos, 1.0);
}

