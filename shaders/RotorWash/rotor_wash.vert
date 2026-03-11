#version 120
varying vec2 v_uv;

void main()
{
    // Vertex position in main camera Screen space.
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    v_uv = gl_MultiTexCoord0.xy;
}

