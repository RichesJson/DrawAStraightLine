//
//  BrushRenderer.m
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/25.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "BrushRenderer.h"
#import "GLKitHelper.h"
#define kBrushOpacity        (1.0 / 3.0)
#define kBrushPixelStep        3
#define kBrushScale            2

#define glError() { \
GLenum err = glGetError(); \
if (err != GL_NO_ERROR) { \
printf("glError: %04x caught at %s:%u\n", err, __FILE__, __LINE__); \
} \
}
typedef NS_ENUM(NSInteger,GLKitHelper_Particle){
    MVP_MATRIX=0,
    POINT_SIZE=1,
    VERTEX_COLOR=2,
    TEXTURE=3,
    BRUSH_UNIFORM=4,
};
@interface BrushRenderer(){
    //创建渲染管理器
    GLint program;
    GLint uniforms[BRUSH_UNIFORM];
    GLfloat brushColor[4];
    GLuint   vboId;
    GLuint   vAoId;
}
@property(nonatomic,strong) GLKitHelper * glkHelper;
@end

@implementation BrushRenderer
//绘制渲染器
- (BOOL)loadShaders{
    
    GLuint vertexShader, fragmentShader;
    NSString *vertexShaderSource, *fragmentShaderSource;
    
    program=glCreateProgram();
    
    //创建顶点渲染器
    vertexShaderSource = [[NSBundle mainBundle] pathForResource:
                                                   @"point" ofType:@"vsh"];
    if (![GLKitHelper compileShader:&vertexShader type:GL_VERTEX_SHADER
                        file:vertexShaderSource])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // 创建片段渲染器.
    fragmentShaderSource = [[NSBundle mainBundle] pathForResource:
                          @"point" ofType:@"fsh"];
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
    
    glBindAttribLocation(program,0,
                         "inVertex");
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
    
//    // Get uniform locations.
    uniforms[MVP_MATRIX] = glGetUniformLocation(program,"MVP");
    uniforms[POINT_SIZE] = glGetUniformLocation(program,"pointSize");
//    uniforms[VERTEX_COLOR] = glGetUniformLocation(program,"vertexColor");
//    uniforms[TEXTURE] = glGetUniformLocation(program,"texture");
     glError();
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
//        // the brush texture will be bound to texture unit 0
//        glUniform1i(uniforms[TEXTURE], 0);
        GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.modelViewMatrix);
        
        
        glUniformMatrix4fv(uniforms[MVP_MATRIX],1, GL_FALSE, MVPMatrix.m);
//        // point size
        glUniform1f(uniforms[POINT_SIZE], 64 /kBrushScale);
//        // initialize brush color
//        glUniform4fv(uniforms[VERTEX_COLOR], 1, brushColor);
    }
    
}




- (void)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    // Update the brush color
    brushColor[0] = red * kBrushOpacity;
    brushColor[1] = green * kBrushOpacity;
    brushColor[2] = blue * kBrushOpacity;
    brushColor[3] = kBrushOpacity;
}


// Drawings a line onscreen based on where the user touches
- (void) drawLine:(CGPoint) start toPoint:(CGPoint) end{
    glUseProgram(program);
    [self createVertexArry:start endPoint:end];
//    [self testDraw];
}

-(void) testDraw{
    glUseProgram(program);
    GLfloat squareVertexData[]={
        224.000000,1656.000000,0.0f,
        226.000000,1657.000000,0.0f,
        230.333328,1659.333374,0.0f,
        232.666656,1660.666626,0.0f,
        240.333328,1730.199951,0.0f,
    };
    glGenBuffers(1, &vboId);
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    //设置顶点数组对象VAO；
    glGenVertexArrays(1, &vAoId);
    //开始记录
    glBindVertexArray(vAoId);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    
    glBindVertexArray(1);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE,5*4,0);
    glDrawArrays(GL_POINTS, 0,5);
}

//-(void) createBufferFrame:(CGPoint) start endPoint:(CGPoint) end{
//    GLfloat *squareVertexData=[self createVertexArry:start endPoint:end verCount:vertCount];
//    glGenBuffers(1, &vboId);
//    glError();
//    glBindBuffer(GL_ARRAY_BUFFER, vboId);
//    glError();
//    glBufferData(GL_ARRAY_BUFFER, 5*2*sizeof(CGFloat), squareVertexData, GL_DYNAMIC_DRAW);
//    glError();
//    //设置顶点数组对象VAO；
//    glGenVertexArrays(1, &vAoId);
//    glError();
//    // 开始记录
//    glBindVertexArray(vAoId);
//    glError();
//    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
//    glError();
//    glBindVertexArray(1);
//    glError();
//    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE,5*4,0);
//    glError();
//    glDrawArrays(GL_LINES, 0,(int) 5);
//    glError();
//}


//绘制顶点数组
-(GLfloat *) createVertexArry:(CGPoint) start endPoint:(CGPoint) end{
    static GLfloat*        squareVertexData = NULL;
    static NSUInteger    vertexMax = 64;
    NSUInteger            vertexCount = 0,
    count,
    i;
    // Convert locations from Points to Pixels
    CGFloat scale = self.scale;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;
    
    // Allocate vertex array buffer
    if(squareVertexData == NULL)
        squareVertexData = malloc(vertexMax * 2 * sizeof(GLfloat));
    // Add points to the buffer so there are drawing points every X pixels
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
    for(i = 0; i < count; ++i) {
        if(vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            squareVertexData = realloc(squareVertexData, vertexMax * 2 * sizeof(GLfloat));
        }
        
        squareVertexData[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        squareVertexData[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        vertexCount += 1;
        NSLog(@"x:%f,y:%f",squareVertexData[2*vertexCount+0],squareVertexData[2*vertexCount+1]);
    }
    glGenBuffers(1, &vboId);
    glError();
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glError();
    glBufferData(GL_ARRAY_BUFFER, vertexCount*2*sizeof(CGFloat), squareVertexData, GL_DYNAMIC_DRAW);
    glError();
    //设置顶点数组对象VAO；
    glGenVertexArrays(1, &vAoId);
    glError();
    // 开始记录
    glBindVertexArray(vAoId);
    glError();
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    glError();
    glBindVertexArray(1);
    glError();
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE,0,0);
    glError();
    glError();
    glDrawArrays(GL_POINTS, 0,(int) vertexCount);
    glError();
    return squareVertexData;
}
@end
