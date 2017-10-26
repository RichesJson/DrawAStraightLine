#version 300 es
layout(location = 0) in vec3 emissionPosition; //位置
layout(location = 1) in vec3 emissionVelocity; //速度
layout(location = 2) in vec3 emissionForce; //受力
layout(location = 3) in vec2 size;  //大小 和 Fade持续时间  size = GLKVector2Make(aSize, aDuration);
layout(location = 4) in vec2 emissionAndDeathTimes; //发射时间 和 消失时间

// UNIFORMS
uniform highp mat4      u_mvpMatrix; //变换矩阵
uniform highp vec3      u_gravity; //重力
uniform highp float     u_elapsedSeconds; //当前时间


// Varyings
varying lowp float      v_particleOpacity; //粒子 不透明度


void main()
{
    highp float elapsedTime = u_elapsedSeconds - a_emissionAndDeathTimes.x; //流逝时间
    
    // 质量假设是1.0 加速度 = 力 (a = f/m)
    // v = v0 + at : v 是当前速度; v0 是初速度;
    //               a 是加速度; t 是时间
    highp vec3 velocity = a_emissionVelocity +
    ((a_emissionForce + u_gravity) * elapsedTime);
    
    // s = s0 + 0.5 * (v0 + v) * t : s 当前位置
    //                              s0 初始位置
    //                              v0 初始速度
    //                              v 当前速度
    //                              t 是时间
    // 运算是对向量运算，相当于分别求出x、y、z的位置，再综合
    highp vec3 untransformedPosition = a_emissionPosition +
    0.5 * (a_emissionVelocity + velocity) * elapsedTime;
    
    //得出点的位置
    gl_Position = u_mvpMatrix * vec4(untransformedPosition, 1.0);
    gl_PointSize = a_size.x / gl_Position.w;    
    
    
    // 消失时间减去当前时间，得到当前的寿命； 除以Fade持续时间，当剩余时间小于Fade时间后，得到一个从1到0变化的值
    // 如果这个值小于0，则取0
    v_particleOpacity = max(0.0, min(1.0,
                                     (a_emissionAndDeathTimes.y - u_elapsedSeconds) /
                                     max(a_size.y, 0.00001)));
}
