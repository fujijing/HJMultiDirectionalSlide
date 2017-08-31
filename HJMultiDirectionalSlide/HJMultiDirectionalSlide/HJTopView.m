//
//  HJTopView.m
//  HJMultiDirectionalSlide
//
//  Created by 黄静静 on 2017/8/28.
//  Copyright © 2017年 HJing. All rights reserved.
//

#import "HJTopView.h"

@implementation HJTopView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:[UIButton class]]) {
        return view;
    }
    NSLog(@" super view == %@",view);
    return nil;
}

@end
