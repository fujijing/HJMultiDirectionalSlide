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
@property (nonatomic) int preIndex;
@property (nonatomic) int curIndex;
@end

@implementation HJSegmentView


+ (instancetype)instanceWithFrame:(CGRect)frame withTitles:(NSArray *)titles withClick:(tabClick)titleClick {
    return [[self alloc] initWithFrame:frame withTitles:titles withClick:titleClick];
}

- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)titles withClick:(tabClick)titleClick {
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = titles;
        self.preIndex = 0;
        self.curIndex = 0;
        self.btnClick = titleClick;
        [self setUIElements];
    }
    return self;
}

- (void)setBottomViewContentOffset:(CGPoint)contentOffset {
    
    if (contentOffset.x >= 2 * HJSegmentTabWidth && contentOffset.x <= 5 * HJSegmentTabWidth) {
        CGPoint point = contentOffset;
        point.x = point.x - 2 * HJSegmentTabWidth;
        self.scrollView.contentOffset = point;
    }
    
    if (self.curIndex >=2 && self.curIndex <= 5) {
        CGRect frame = self.bottomLine.frame;
        frame.origin.x = 2 * HJSegmentTabWidth;
        self.bottomLine.frame = frame;
    } else {
        CGRect frame = self.bottomLine.frame;
        frame.origin.x = contentOffset.x - (self.curIndex > 5 ? (3 * HJSegmentTabWidth) : 0);
        self.bottomLine.frame = frame;
    }
    
    self.curIndex = ( contentOffset.x + HJSegmentTabWidth/2 ) / ([UIScreen mainScreen].bounds.size.width/5);
    [self changeButtonStateWithPreIndex:self.preIndex curIndex:self.curIndex];
    self.preIndex = self.curIndex;
    
}

- (void)changeButtonStateWithPreIndex:(int)preIndex curIndex:(int)curIndex {
    NSLog(@"----------------pre index = %d, cur index = %d",preIndex,curIndex);
    
    UIButton *preBtn = self.allBtn[preIndex];
    UIButton *curBtn = self.allBtn[curIndex];
    [preBtn setTitleColor:self.buttonNormalColor forState:UIControlStateNormal];
    [curBtn setTitleColor:self.buttonSelectColor forState:UIControlStateNormal];
}

- (void)buttonAction:(UIButton *)button {
    
    if (button.tag == self.preIndex) {
        return;
    }
    
    UIButton *preBtn = self.allBtn[self.preIndex];
    [preBtn setTitleColor:self.buttonNormalColor forState:UIControlStateNormal];
    
    self.curIndex = (int)button.tag;
    
    if (self.btnClick) {
        self.btnClick(self.curIndex);
    }
}

#pragma mark - UI

- (void)setUIElements {
    [self addSubview:self.scrollView];
    self.scrollView.contentSize = CGSizeMake(HJSegmentTabWidth * self.titles.count, HJSegmentTabHeight);
//    NSLog(@"self.scrollView.contentSize = %f",self.scrollView.contentSize.width);
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
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        [self.allBtn addObject:button];
    }
    
}

- (void)setBottomLine {
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
