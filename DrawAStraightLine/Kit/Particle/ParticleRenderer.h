//
//  ParticleRenderer.h
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/25.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
@interface ParticleRenderer : NSObject
@property(nonatomic,assign) GLKMatrix4 projectionMatrix;
@property(nonatomic,assign) GLKMatrix4 modelViewMatrix;
@property (nonatomic, assign) GLKVector3 gravity;
@property (nonatomic, assign) GLfloat elapsedSeconds;
@end
