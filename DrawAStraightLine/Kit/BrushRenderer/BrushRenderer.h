//
//  BrushRenderer.h
//  DrawAStraightLine
//  艺术字渲染器-画笔
//  Created by richsjeson on 2017/10/25.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>

@interface BrushRenderer : NSObject
@property(nonatomic,assign) GLKMatrix4 projectionMatrix;
@property(nonatomic,assign) GLKMatrix4 modelViewMatrix;
//计算屏幕的比例
@property(nonatomic,assign) CGFloat scale;
//设置颜色
-(void)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
//执行渲染
- (void)prepareToDraw;
- (void) drawLine:(CGPoint) start toPoint:(CGPoint) end;
- (void) testDraw;
@end
