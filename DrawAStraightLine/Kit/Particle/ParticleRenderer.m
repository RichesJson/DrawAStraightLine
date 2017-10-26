//
//  ParticleRenderer.m
//  DrawAStraightLine
//  粒子效果
//  Created by richsjeson on 2017/10/25.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "ParticleRenderer.h"
#import "GLKitHelper.h"
#define glError() { \
GLenum err = glGetError(); \
if (err != GL_NO_ERROR) { \
printf("glError: %04x caught at %s:%u\n", err, __FILE__, __LINE__); \
} \
}
typedef NS_ENUM(NSInteger,GLKitHelper_PointParticle){
    //位置
    EMISSON_POSITION=0,
    //速度
    EMISSION_VELOCITY=1,
    //受力
    EMISSION_FORCE=2,
    //粒子大小
    EMISSION_SIZE=3,
    //发射和消失时间
    EMISSION_DETACHTIMES=4,
};
typedef NS_ENUM(NSInteger,GLKitHelper_Uniform_PointParticle){
    //位置
    MVP_MATRIX=0,
    //速度
    ELASPED_SECONDS=1,
    //受力
    GRAVITY=2,
    UNIFORM_PARTICLE=3,
};
@interface ParticleRenderer(){
    GLuint program;
    GLint uniforms[UNIFORM_PARTICLE];
}
@end
@implementation ParticleRenderer
@synthesize gravity;
@synthesize elapsedSeconds;
//绘制渲染器
- (BOOL)loadShaders{
    
    GLuint vertexShader, fragmentShader;
    NSString *vertexShaderSource, *fragmentShaderSource;
    
    program=glCreateProgram();
    
    //创建顶点渲染器
    vertexShaderSource = [[NSBundle mainBundle] pathForResource:
                          @"PointParticle" ofType:@"vsh"];
    if (![GLKitHelper compileShader:&vertexShader type:GL_VERTEX_SHADER
                               file:vertexShaderSource])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // 创建片段渲染器.
    fragmentShaderSource = [[NSBundle mainBundle] pathForResource:
                            @"PointParticle" ofType:@"fsh"];
    if (![GLKitHelper compileShader:&fragmentShader type:GL_FRAGMENT_SHADER
                               file:fragmentShaderSource])
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertexShader);
    glError();
    // Attach fragment shader to program.
    glAttachShader(program, fragmentShader);
    glError();
    
    glBindAttribLocation(program, EMISSON_POSITION,
                         "emissionPosition");
    glBindAttribLocation(program, EMISSION_VELOCITY,
                         "emissionVelocity");
    glBindAttribLocation(program, EMISSION_FORCE,
                         "emissionForce");
    glBindAttribLocation(program, EMISSION_SIZE,
                         "size");
    glBindAttribLocation(program, EMISSION_DETACHTIMES,
                         "emissionAndDeathTimes");
    glError();
    if (![GLKitHelper linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertexShader)
        {
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        if (fragmentShader)
        {
            glDeleteShader(fragmentShader);
            fragmentShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return NO;
    }
    glError();
    
    // Get uniform locations.
    uniforms[MVP_MATRIX] = glGetUniformLocation(program,
                                                   "u_mvpMatrix");
    uniforms[GRAVITY] = glGetUniformLocation(program,
                                                 "u_gravity");
    uniforms[ELASPED_SECONDS] = glGetUniformLocation(program,
                                                        "u_elapsedSeconds");
    
    // Delete vertex and fragment shaders.
    if (vertexShader)
    {
        glDetachShader(program, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader)
    {
        glDetachShader(program, fragmentShader);
        glDeleteShader(fragmentShader);
    }
    //    free(&vertexShaderSource);
    //    free(&fragmentShaderSource);
    
    return YES;
}

//
- (void)prepareToDraw{
    //如果program没有初始化
    if(program==0){
        [self loadShaders];
    }else{
        //渲染时赋值
        glUseProgram(program);
        // Precalculate the mvpMatrix
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix,self.modelViewMatrix);
        glUniformMatrix4fv(uniforms[MVP_MATRIX], 1, 0,
                           modelViewProjectionMatrix.m);
        // Particle physics
        glUniform3fv(uniforms[GRAVITY], 1, self.gravity.v);
        glUniform1fv(uniforms[ELASPED_SECONDS], 1,  &elapsedSeconds);
    }
    
}




@end
