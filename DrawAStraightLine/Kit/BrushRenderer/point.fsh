//uniform sampler2D texture;
//varying lowp vec4 color;
//
#version 300 es
precision highp float;
layout(location = 0) out vec4 aFrag;
void main()
{
//    gl_FragColor = color * texture2D(texture, gl_PointCoord);
    aFrag=vec4(1.0f, 0.5f, 0.2f, 1.0f);
}

