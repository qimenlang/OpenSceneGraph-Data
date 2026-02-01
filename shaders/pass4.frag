#version 120
uniform sampler2DRect sceneColor;
// uniform sampler2D sceneColor;
void main()
{
    gl_FragColor = texture2DRect(sceneColor, gl_FragCoord.xy);
    // gl_FragColor = texture2D(sceneColor, gl_FragCoord.xy);
    // gl_FragColor = vec4(vec3(1.0, 0.0, 0.0),1.0);
}
