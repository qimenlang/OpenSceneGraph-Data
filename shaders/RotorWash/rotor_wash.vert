#version 120
varying vec2 v_uv;
varying vec3 v_normal;

varying vec3 cameraPos;
varying vec3 fragPos;

uniform mat4 osg_ViewMatrixInverse;


float oceanHeight(vec2 uv);
// 根据高度图计算法线
vec3 getNormal(vec2 p);


void main()
{
    // Vertex position in main camera Screen space.
    v_uv = gl_MultiTexCoord0.xy;

    vec3 vertexPos = gl_Vertex.xyz;

    // vertexPos.z = oceanHeight(v_uv);
    v_normal = getNormal(v_uv);
    // vertexPos.z = sin(v_uv.x * 20.0 - iTime * 5.0)*0.1;

    cameraPos = osg_ViewMatrixInverse[3].xyz;

    mat4 modelMatrix = osg_ViewMatrixInverse * gl_ModelViewMatrix;
    fragPos = (modelMatrix * vec4(vertexPos,1.0)).xyz;

    gl_Position = gl_ModelViewProjectionMatrix * vec4(vertexPos, 1.0);
}

