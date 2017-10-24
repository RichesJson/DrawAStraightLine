//
//  BrushRenderer.h
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/24.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/EAGLDrawable.h>
@interface BrushRenderer : NSObject
- (void)prepareToDraw;
- (void) drawLine:(CGPoint)start toPoint:(CGPoint)end;
- (void) setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
- (void) initOpenGL;
@property(nonatomic,strong) EAGLContext *context;
@end
