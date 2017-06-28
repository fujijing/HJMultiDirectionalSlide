//
//  HJSegmentView.m
//  HJMultiDirectionalSlide
//
//  Created by 黄静静 on 2017/6/27.
//  Copyright © 2017年 HJing. All rights reserved.
//

#import "HJSegmentView.h"

#define HJSegmentTabWidth HJScreenWidth/5
#define HJSegmentTabHeight 48
#define HJColor(r,g,b,a)  [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:a]

@interface  HJSegmentView()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) NSArray *titles;   //store the titles of all the buttons
@property (nonatomic, strong) NSMutableArray *allBtn;  // store all the buttons
@end

@implementation HJSegmentView


+ (instancetype)instanceWithFrame:(CGRect)frame withTitles:(NSArray *)titles withClick:(tabClick)titleClick {
    return [[self alloc] initWithFrame:frame withTitles:titles withClick:titleClick];
}

- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)titles withClick:(tabClick)titleClick {
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = titles;
        [self setUIElements];
    }
    return self;
}

- (void)setBottomViewContentOffset:(CGPoint)contentOffset {
    CGRect frame = self.bottomLine.frame;
    frame.origin.x = contentOffset.x;
    self.bottomLine.frame = frame;
}

#pragma mark - UI

- (void)setUIElements {
    [self addSubview:self.scrollView];
    self.scrollView.contentSize = CGSizeMake(HJSegmentTabWidth * self.titles.count, HJSegmentTabHeight);
    
    [self setAllButtons];
    [self setBottomLine];
}

- (void)setAllButtons {
    
    for (int i = 0; i < self.titles.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * HJSegmentTabWidth, 0, HJSegmentTabWidth, HJSegmentTabHeight)];
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setTitleColor: i == 0 ? self.buttonSelectColor : self.buttonNormalColor forState:UIControlStateNormal];
        button.tag = i;
        [self.scrollView addSubview:button];
        [self.allBtn addObject:button];
    }
}

- (void)setBottomLine{
    self.bottomLine = [[UIView alloc ] initWithFrame:CGRectMake(0, HJSegmentTabHeight, HJSegmentTabWidth, 2)];
    self.bottomLine.backgroundColor = self.bottomViewColor;
    [self addSubview:self.bottomLine];
}


#pragma mark - lazy init

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, HJScreenWidth, HJSegmentTabHeight)];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (NSMutableArray *)allBtn {
    if (_allBtn == nil) {
        _allBtn = [NSMutableArray array];
    }
    return _allBtn;
}

- (UIColor *)buttonNormalColor {
    if (_buttonNormalColor == nil) {
        _buttonNormalColor = HJColor(146, 146, 146, 1.0);
    }
    return _buttonNormalColor;
}

- (UIColor *)buttonSelectColor {
    if (_buttonSelectColor == nil) {
        _buttonSelectColor = HJColor(0, 0, 0, 1.0);
    }
    return _buttonSelectColor;
}

- (UIColor *)bottomViewColor {
    if (_bottomViewColor == nil) {
        _bottomViewColor = HJColor(255, 109, 45, 1.0);
    }
    return _bottomViewColor;
}

@end
