//
//  HJSegmentView.h
//  HJMultiDirectionalSlide
//
//  Created by 黄静静 on 2017/6/27.
//  Copyright © 2017年 HJing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^tabClick)(NSInteger index);

@interface HJSegmentView : UIView

@property (nonatomic, strong) UIColor *buttonSelectColor;
@property (nonatomic, strong) UIColor *buttonNormalColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *bottomViewColor;

@property (nonatomic, copy) tabClick btnClick;

/*
 *  Initialization method
 */
+ (instancetype)instanceWithFrame:(CGRect)frame withTitles:(NSArray *)titles withClick:(tabClick)titleClick;

- (void)setBottomViewContentOffset:(CGPoint)contentOffset;

@end
