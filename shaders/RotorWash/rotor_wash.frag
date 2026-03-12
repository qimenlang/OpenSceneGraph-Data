#version 120
varying vec2 v_uv;
varying vec3 v_normal;


void main() {
    vec3 color = vec3(0.0, 0.45, 0.65); // 海蓝色
    color = vec3(v_uv, 0.0);
    color = vec3(floor(v_uv.x*100.0)/100.0, floor(v_uv.y*100.0)/100.0, 0.0); // 网格线效果

    // 红绿网格
    // float cells = 50.0;                // 每行/列的格子数
    // vec2 cellIndex = floor(v_uv * cells); // 当前像素所在的格子索引
    // float even = mod(cellIndex.x + cellIndex.y, 2.0); // 奇偶判断
    // // 偶数格子为红色，奇数格子为绿色
    // color = even < 0.5 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0);

    gl_FragColor = vec4(color, 1.0);
}