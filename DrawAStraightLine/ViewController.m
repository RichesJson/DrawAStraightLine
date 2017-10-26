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
#import "GLKitView.h"
#import "BrushRenderer.h"
#import "AGLKPointParticleEffect.h"
#import <GLKit/GLKBaseEffect.h>
#define WIDTH  [[UIScreen mainScreen]bounds].size.width
#define HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCALE  [[UIScreen mainScreen] scale]

#define kBrushOpacity        (1.0 / 3.0)
#define kBrushPixelStep        3
#define kBrushScale            2

#define kBrightness             1.0
#define kSaturation             0.45

#define kPaletteHeight            30
#define kPaletteSize            5
#define kMinEraseInterval        0.5

// Padding for margins
#define kLeftMargin                10.0
#define kTopMargin                10.0
#define kRightMargin            10.0
@interface ViewController ()<GLKitViewDelegate>{
    Boolean firstTouch;
    GLuint   vboId;
    GLuint   vAoId;
    CADisplayLink     *displayLink;
    NSInteger         preferredFramesPerSecond;
}
@property(nonatomic,strong) EAGLContext * mContext;
@property(nonatomic,strong) BrushRenderer * brushRenderer;
@property(nonatomic,readwrite) CGPoint location;
@property(nonatomic,readwrite) CGPoint previousLocation;
@property(nonatomic,strong) GLKitView *glkView;
@property (strong, nonatomic) AGLKPointParticleEffect *particleEffect;
@property (assign, nonatomic) NSTimeInterval autoSpawnDelta;
@property (assign, nonatomic) NSTimeInterval lastSpawnTime;
@property (strong, nonatomic) NSArray *emitterBlocks;

@end

@implementation ViewController
@synthesize  location;
@synthesize  previousLocation;
@synthesize  glkView;
- (void)viewDidLoad {
    [super viewDidLoad];
    displayLink =
    [CADisplayLink displayLinkWithTarget:self
                                selector:@selector(drawView)];
    
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
    self.mContext=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    glkView = [[GLKitView alloc] initWithFrame:self.view.bounds];
    glkView.delegate=self;
    glkView.context=self.mContext;
    self.view=glkView;

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glClearColor(0.1, 0.2, 0.3, 1);
    
    self.brushRenderer=[[BrushRenderer alloc] init];
    self.brushRenderer.projectionMatrix=GLKMatrix4MakeOrtho(0,WIDTH,0, HEIGHT, -1, 1);
    self.brushRenderer.modelViewMatrix=GLKMatrix4Identity;
    self.brushRenderer.scale=SCALE;
    CGColorRef color = [UIColor colorWithHue:(CGFloat)2.0 / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
    // Defer to the OpenGL view to set the brush color
    [self.brushRenderer colorWithRed:components[0] green:components[1] blue:components[2]];
    
    self.particleEffect = [[AGLKPointParticleEffect alloc] init];
    [self preparePointOfViewWithAspectRatio:
     CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds)];
}


- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
    
    self.particleEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(85.0f),
                              aspectRatio,
                              0.1f,
                              20.0f);
    
    self.particleEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0, 0.0, 1.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.1, 0.2, 0.3, 1);
    //启动着色器
    glClear(GL_COLOR_BUFFER_BIT);
//    [self.brushRenderer prepareToDraw];
    [self.particleEffect prepareToDraw];
    [self.particleEffect draw];
    [glkView  start];
    [self update];
    [glkView render];
 
    
}

- (void)update
{
//    NSTimeInterval timeElapsed = [self framesPerSecond];
//
//    self.particleEffect.elapsedSeconds = timeElapsed;

//    if(self.autoSpawnDelta < (timeElapsed - self.lastSpawnTime))
//    {
//        self.lastSpawnTime = timeElapsed;

        self.autoSpawnDelta = 0.5f;

        self.particleEffect.gravity = GLKVector3Make(
                                                     0.0f, 0.0f, 0.0f);

        for(int i = 0; i < 100; i++)
        {
            float randomXVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;

            [self.particleEffect
             addParticleAtPosition:GLKVector3Make(0.5f,0.5f, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     randomYVelocity,
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.5f];
        }
//    }
    //    if(timeElapsed==30){
    //        UIImage * image=[self glToUIImage];
//    NSLog(@"");
    //    }


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

//-(CGPoint)convertToGL:(CGPoint) uiPoint
//{
//    GLKMatrix4 transform = self.projectionMatrix;
//    GLKMatrix4 invTransform = GLKMatrix4Invert(transform, NULL);
//
//    // Calculate z=0 using -> transform*[0, 0, 0, 1]/w
//    float zClip = transform.m[14]/transform.m[15];
//
//    CGSize glSize = self.view.bounds.size;
//    GLKVector3 clipCoord = GLKVector3Make(2.0*uiPoint.x/glSize.width - 1.0, 2.0*uiPoint.y/glSize.height - 1.0, zClip);
//
//    clipCoord.y *= -1.0;
//
//    GLKVector3 glCoord = GLKMatrix4MultiplyAndProjectVector3(invTransform, clipCoord);
////    NSLog(@"x:%f,---- porjectX:%f",uiPoint.x,glCoord.x);
////    NSLog(@"y:%f,---- porjectY:%f",uiPoint.y,glCoord.y);
//    return CGPointMake(glCoord.x, glCoord.y);
//}

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect                bounds = [self.view bounds];
    UITouch*            touch = [[event touchesForView:glkView] anyObject];
    firstTouch = YES;
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    location = [touch locationInView:self.view];
    location.y = bounds.size.height - location.y;
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect                bounds = [self.view bounds];
    UITouch*            touch = [[event touchesForView:glkView] anyObject];
    
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:glkView];
        previousLocation.y = bounds.size.height - previousLocation.y;
    } else {
        location = [touch locationInView:self.view];
        location.y = bounds.size.height - location.y;
        previousLocation = [touch previousLocationInView:glkView];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }
    
    // Render the stroke
    if(self.brushRenderer){
        [glkView start];
        [self.brushRenderer drawLine:previousLocation toPoint:location];
//        [self update];
        [glkView render];
        
    }
  
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect                bounds = [self.view bounds];
    UITouch*            touch = [[event touchesForView:glkView] anyObject];
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:glkView];
        previousLocation.y = bounds.size.height - previousLocation.y;
        if(self.brushRenderer){
            [glkView start];
            [self.brushRenderer drawLine:previousLocation toPoint:location];
//            [self update];
            [glkView render];
        }
    }
}

-(void) drawView{
    [glkView display];
}
@end
