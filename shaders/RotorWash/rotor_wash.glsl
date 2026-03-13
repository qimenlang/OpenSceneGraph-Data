const float PI = 3.14159265359;
uniform float iTime;
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

    // --- 随机角向扰动 ---
    float angleNoise =
        sin(a*7.0 + r*8.0 + t*1.7)
        *sin(a*13.0 - r*5.0 - t*1.3);

    float radialSpeed = 8.88;
    float radialFreq = 60.0;

    float nosieFreq = 3.0;
    float nosieRotateSpeed = 0.0;

    // --- 半径扰动 ---
    r = r + 0.027 * angleNoise;


    float noise =
        sin(a * 24.0 *nosieFreq+ t * 2.0*nosieRotateSpeed) *
        sin(a * 13.0 *nosieFreq - t * 1.5*nosieRotateSpeed);

    // 径向
    float radial =
        sin(r * radialFreq - t * radialSpeed);
    
    // 畸变,带了旋转
    float distort =
        sin(a * 12.0 + r * 20.0 + t * 3.0);

    // 随距离衰减,0.1处最强；0.0-0.2范围内衰减
    float highpoint = 0.2;
    // float decl = clamp(1.0-  pow(r - highpoint,2.0)/pow(highpoint,2.0), 0.0, 1.0);
    float decl = clamp(1.0 -  44.4*pow(r - highpoint,2.0), 0.0, 1.0);
    // 随距离衰减
    // decl *= exp(-r*declRatio);
 
    // decl = step(r, 0.2);
    
    float noiseheight = hashNoise(uv*100);
    float noisehash = hash(uv);

    float height = (0.6 * radial + 0.4 * noise * distort);
    // height = abs(0.6 * radial + 0.4 * noise);
    height = (0.6 * radial + 0.4 * noise);



    // height = decl * radial;

    // height = decl * noise;

    // height += noiseheight; //0-2
    // height *= noiseheight;
    height *= amp;// 0-0.2
    // height -= amp; //[-0.1,0.1]
    // if(noiseheight<0.5)
    //     height = 0.0;

    height*=decl;
    // height/=2.0;

    // height = noiseheight*amp;
    // height = noisehash;

    return height;
}

float hash2(float x)
{
    return fract(sin(x*123.34)*456.21);
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
    float len = 0.04;
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
    height*=0.3;// 整体缩放系数，控制波浪高度
    return height;
}

// 根据高度图计算法线,前向差分
vec3 getNormalPre(vec2 p)
{
    float e=0.002;

    float h=oceanHeight(p);
    float hx=oceanHeight(p+vec2(e,0));
    float hy=oceanHeight(p+vec2(0,e));

    return normalize(vec3(h-hx,e,h-hy));
}

// 中心差分
vec3 getNormalMid(vec2 p) {
    float e = 0.002; // 步长，可根据纹理像素大小调整

    float hL = oceanHeight(p - vec2(e, 0.0));
    float hR = oceanHeight(p + vec2(e, 0.0));
    float hD = oceanHeight(p - vec2(0.0, e));
    float hU = oceanHeight(p + vec2(0.0, e));

    // 直接构建法线向量（等价于中心差分）
    return normalize(vec3(hL - hR, 2.0 * e, hD - hU));
}

vec3 getNormal(vec2 p){
    return getNormalMid(p);
}
