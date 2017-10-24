//
//  Cofetti.h
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/24.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/EAGLDrawable.h>
@interface Cofetti : UIView
@property(nonatomic,strong) EAGLContext *context;
@end
