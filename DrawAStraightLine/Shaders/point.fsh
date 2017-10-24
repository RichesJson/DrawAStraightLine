uniform sampler2D texture;
varying lowp vec4 color;

void main()
{
//    gl_FragColor = color * texture2D(texture, gl_PointCoord);
    gl_FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
