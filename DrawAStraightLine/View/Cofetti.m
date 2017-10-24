//
//  Cofetti.m
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/24.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "Cofetti.h"
#include "shaderUtil.h"
#include "fileUtil.h"
#import "BrushRenderer.h"
#define kBrushOpacity        (1.0 / 3.0)
#define kBrushPixelStep        3
#define kBrushScale            2
@interface Cofetti(){
    GLfloat brushColor[4];
    Boolean    firstTouch;
}
@property(nonatomic,strong) EAGLContext *context;
@property(nonatomic,readwrite) CGPoint location;
@property(nonatomic,readwrite) CGPoint previousLocation;
@property(nonatomic,strong) BrushRenderer * brushRenderer;
@end
@implementation Cofetti
@synthesize  location;
@synthesize  previousLocation;

- (instancetype)initWithFrame:(CGRect)frame{
    
    
    if(self==[super initWithFrame:frame]){
        
        if(!self.brushRenderer){
           self.brushRenderer=[[BrushRenderer alloc] init];
        }
    }
    return self;
    
}


-(void)layoutSubviews
{
    [EAGLContext setCurrentContext:self.context];
    if (!initialized) {
        initialized = [self initGL];
    }
    else {
        [self resizeFromLayer:(CAEAGLLayer*)self.layer];
    }
}




- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    return YES;
}
- (BOOL)initGL
{
    if(self.brushRenderer){
        [self.brushRenderer initOpenGL];
    }
    return YES;
}
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect                bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    firstTouch = YES;
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    location = [touch locationInView:self];
    location.y = bounds.size.height - location.y;
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect                bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    } else {
        location = [touch locationInView:self];
        location.y = bounds.size.height - location.y;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }
    
    // Render the stroke
    
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect                bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
        
    }
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If appropriate, add code necessary to save the state of the application.
    // This application is not saving state.
    NSLog(@"cancell");
}



@end
