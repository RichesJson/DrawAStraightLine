//
//  GLKitHelper.h
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/25.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
@interface GLKitHelper : NSObject
//Shader读取操作
+ (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file;
+(BOOL)linkProgram:(GLuint)prog;
@end
