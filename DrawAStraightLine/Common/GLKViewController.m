//
//  GLKViewController.m
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/25.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "GLKViewController.h"

@interface GLKViewController (){
    CADisplayLink     *displayLink;
    NSInteger         preferredFramesPerSecond;
}
@end

@implementation GLKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    displayLink =
    [CADisplayLink displayLinkWithTarget:self
                                selector:@selector(drawView)];
    
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
