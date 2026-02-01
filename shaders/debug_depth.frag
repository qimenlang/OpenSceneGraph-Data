#version 330 core
in vec2 vUV;
out vec4 FragColor;

uniform sampler2D uDepthTex;

void main()
{
    float d = texture(uDepthTex, vUV).r;
    FragColor.rgb = vec3(1,0,0);
    FragColor = vec4(vec3(d), 1.0);
}
