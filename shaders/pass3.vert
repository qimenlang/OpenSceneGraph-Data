#version 120
void main()
{
    // Vertex position in main camera Screen space.
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    gl_TexCoord[0] = gl_MultiTexCoord0; 
}

