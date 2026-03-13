#version 120
varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 cameraPos;
varying vec3 fragPos;

uniform mat4 osg_ViewMatrixInverse;


void main() {
    vec3 color = vec3(0.0, 0.45, 0.65); // 海蓝色
    color = vec3(v_uv, 0.0);
    color = vec3(floor(v_uv.x*100.0)/100.0, floor(v_uv.y*100.0)/100.0, 0.0); // 网格线效果

    // shading
    vec3 lightDir = normalize(vec3(1.0,1.0,1.0));

    float diff=max(dot(v_normal,lightDir),0.0);

    vec3 deep=vec3(0.0,0.15,0.35);
    vec3 shallow=vec3(0.0,0.55,0.85);
    color = mix(deep,shallow,diff);

    vec3 viewDir = normalize(cameraPos-fragPos);
    vec3 reflectDir = reflect(-lightDir,v_normal);
    float spec = pow(max(dot(viewDir,reflectDir),0.0),16);

    // color += spec*vec3(1.0);

    // color = normalize(v_normal) * 0.5 + 0.5; // 法线可视化
    // color = normalize(camPos - v_normal) * 0.5 + 0.5; // 视线方向可视化
    // color = normalize(v_normal);

    gl_FragColor = vec4(color, 1.0);
}