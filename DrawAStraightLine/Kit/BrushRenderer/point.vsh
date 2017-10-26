#version 300 es
layout(location = 0) in vec4 inVertex;
uniform mat4 MVP;
uniform float pointSize;

void main()
{
    gl_Position = MVP * inVertex;
    gl_PointSize = pointSize;
////    1 * 3.0;
//    color = vertexColor;
}
