#version 120

uniform sampler2D rippleTex;
uniform float iTime;

varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 cameraPos;
varying vec3 fragPos;

const float PI = 3.14159265359;


// 根据高度图计算法线
vec3 getNormal(vec2 p);
float hashNoise(vec2 p);


void main() {
    vec3 color = vec3(0.0, 0.45, 0.65); // 海蓝色
    color = vec3(v_uv, 0.0);
    color = vec3(floor(v_uv.x*100.0)/100.0, floor(v_uv.y*100.0)/100.0, 0.0); // 网格线效果

    // shading
    vec3 lightDir = normalize(vec3(1.0,1.0,1.0));

    lightDir = normalize(vec3(0.0,0.0,1.0));

    // [-1,1]范围的法线，还没转到世界空间
    vec3 normal = getNormal(v_uv);
    // vec3 normal = v_normal;
    // color = normalize(v_normal);

    float diff=max(dot(normal,lightDir),0.0);

    vec3 deep=vec3(0.0,0.15,0.35);
    vec3 shallow=vec3(0.0,0.55,0.85);
    color = mix(deep,shallow,diff);

    // color = vec3(diff);
    // color = shallow*diff;

    vec3 viewDir = normalize(cameraPos-fragPos);
    vec3 reflectDir = reflect(-lightDir,normal);
    float spec = pow(max(dot(viewDir,reflectDir),0.0),16);

    // 真是水体模型：
    // color = mix(refraction, reflection, fresnel)

    // color = shallow;
    
    // 法线可视化
    // color = normal*0.5+0.5;
    // color = normal;
    // color = vec3(v_uv,0);

    gl_FragColor = vec4(color, 1.0);
}