//
//  GLKitView.h
//  DrawAStraightLine
//  定义一个通用的GLKView
//  Created by richsjeson on 2017/10/25.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGLDrawable.h>
#pragma mark - GLKitViewDelegate
@protocol GLKitViewDelegate <NSObject>
@required
- (void)glkView:(UIView *)view drawInRect:(CGRect)rect;
@end
typedef enum
{
    GLKitViewDrawableDepthFormatNone = 0,
    GLKitViewDrawableDepthFormat16,
}   GLKitViewDrawableDepthFormat;
@interface GLKitView : UIView
@property(nonatomic,strong) EAGLContext * context;
@property (nonatomic, readonly) NSInteger drawableWidth;
@property (nonatomic, readonly) NSInteger drawableHeight;
@property (nonatomic) GLKitViewDrawableDepthFormat drawableDepthFormat;
@property (nonatomic, weak) id<GLKitViewDelegate> delegate;
-(void)display;
-(void) render;
-(void) start;
@end


