//
//  ViewController.m
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/20.
//  Copyright © 2017年 richsjeson. All rights reserved.
//  绘制直线
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKBaseEffect.h>
#import "AGLKPointParticleEffect.h"
@interface ViewController ()
@property(nonatomic,strong) EAGLContext * mContext;
@property(nonatomic,strong) GLKBaseEffect *effect;
@property (strong)  NSMutableArray *touchArray;  //单前绘制的点阵
@property (strong)  NSMutableArray *allTouchArray; //总绘制点阵
@property (strong, nonatomic) AGLKPointParticleEffect *particleEffect;
@property (assign, nonatomic) NSTimeInterval autoSpawnDelta;
@property (assign, nonatomic) NSTimeInterval lastSpawnTime;
@property (strong, nonatomic) NSArray *emitterBlocks;
/// Projection matrix used for rendering.
/// @see projection
@property(nonatomic, assign) GLKMatrix4 projectionMatrix;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mContext=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    GLKView *view = (GLKView *)self.view;
    view.context=self.mContext;
    view.drawableColorFormat=GLKViewDrawableColorFormatRGBA8888;
    glClearColor(0.1, 0.2, 0.3, 1);
    [EAGLContext setCurrentContext:self.mContext];
    self.effect=[[GLKBaseEffect alloc] init] ;
    self.effect.useConstantColor=GL_TRUE;
    self.effect.constantColor=GLKVector4Make(0.0f, 1.0f, 1.0f, 1.0f);
    self.allTouchArray = [NSMutableArray array];
    self.particleEffect = [[AGLKPointParticleEffect alloc] init];
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [self preparePointOfViewWithAspectRatio:
     CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds)];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    //启动着色器
    glClear(GL_COLOR_BUFFER_BIT);
    [self.effect prepareToDraw];
    [self uploadVertexArray];
//    [self.particleEffect prepareToDraw];
//    [self.particleEffect draw];


}



-(void) uploadVertexArray{
    NSLog(@"touchCont:%d",self.touchArray.count);
    for (int i = 1; i < self.touchArray.count; i++) {
        CGPoint prevPoint = CGPointFromString(self.touchArray[i-1]);
        CGPoint firstPoint = prevPoint;
        if (i > 1) {
            firstPoint = CGPointFromString(self.touchArray[i-2]);
        }
        CGPoint currentPoint = CGPointFromString(self.touchArray[i]);
        CGPoint mid1 = [self convertToGL:(midPoint(prevPoint, firstPoint))];
        CGPoint mid2 = [self convertToGL:(midPoint(currentPoint, prevPoint))];
//        CGPoint mid1 = [self convertToGL:prevPoint];
//        CGPoint mid2 = [self convertToGL:currentPoint];
        GLfloat line[]={
                    mid1.x,mid1.y, 0.0f, // left
                    mid2.x,mid2.y,0.0f,
                };
        GLuint bufferObjectNameArray;
        glGenBuffers(1, &bufferObjectNameArray);
        glBindBuffer(GL_ARRAY_BUFFER, bufferObjectNameArray);
        glBufferData(GL_ARRAY_BUFFER, sizeof(line), line, GL_STATIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 2*4, NULL);
        glDrawArrays(GL_LINES, 0, 2);
        
    }
}


CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

CGFloat mi3DProjectdPointX(int x)
{
    CGFloat projectX;
    projectX=2*x/[[UIScreen mainScreen]bounds].size.width-1;
    projectX=projectX*[[UIScreen mainScreen]bounds].size.width/[[UIScreen mainScreen]bounds].size.height;
//    NSLog(@"x:%f,---- porjectX:%f",x,projectX);
    return projectX;
}
CGFloat mi3DProjectdPointY(int y){
    CGFloat projectY;
    projectY=  1-2*y/[[UIScreen mainScreen]bounds].size.height;
//    NSLog(@"y:%f,--- porjectY:%f",y,projectY);
    return projectY;
}
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.touchArray = [NSMutableArray array];
    [self.allTouchArray addObject:self.touchArray];
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    [self.touchArray addObject:NSStringFromCGPoint(pt)];
}

-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
//    CGPoint projectOpenGL= [self convertToGL:pt];
    [self.touchArray addObject:NSStringFromCGPoint(pt)];
}

-(void) toucheCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

- (void)update
{

}


-(UIImage *) glToUIImage {
    
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    GLint width= size_screen.width*scale_screen;// CGRectGetWidth(self.view.bounds)*4;
    GLint height= size_screen.height*scale_screen;//CGRectGetHeight(self.view.bounds)*4;
    NSInteger myDataLength = width *height * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
//    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
//    for(int y = 0; y <height; y++)
//    {
//        for(int x = 0; x <width * 4; x++)
//        {
//            buffer2[(height-1 - y) * width * 4 + x] = buffer[y * 4 * width + x];
//        }
//    }
//
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, NULL);
//    width/=2;
//    height/=2;
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}

-(CGPoint)convertToGL:(CGPoint) uiPoint
{
    GLKMatrix4 transform = self.projectionMatrix;
    GLKMatrix4 invTransform = GLKMatrix4Invert(transform, NULL);
    
    // Calculate z=0 using -> transform*[0, 0, 0, 1]/w
    float zClip = transform.m[14]/transform.m[15];
    
    CGSize glSize = self.view.bounds.size;
    GLKVector3 clipCoord = GLKVector3Make(2.0*uiPoint.x/glSize.width - 1.0, 2.0*uiPoint.y/glSize.height - 1.0, zClip);
    
    clipCoord.y *= -1.0;
    
    GLKVector3 glCoord = GLKMatrix4MultiplyAndProjectVector3(invTransform, clipCoord);
//    NSLog(@"x:%f,---- porjectX:%f",uiPoint.x,glCoord.x);
//    NSLog(@"y:%f,---- porjectY:%f",uiPoint.y,glCoord.y);
    return CGPointMake(glCoord.x, glCoord.y);
}


@end
