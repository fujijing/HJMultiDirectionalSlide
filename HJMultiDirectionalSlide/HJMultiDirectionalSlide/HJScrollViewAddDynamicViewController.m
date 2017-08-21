//
//  HJScrollViewAddDynamicViewController.m
//  HJMultiDirectionalSlide
//
//  Created by 黄静静 on 2017/8/21.
//  Copyright © 2017年 HJing. All rights reserved.
//

#import "HJScrollViewAddDynamicViewController.h"
#import "HJSegmentView.h"
#import "LJDynamicItem.h"

#define HJTopViewHeight 200
#define HJSegmentViewH  50

/*f(x, d, c) = (x * d * c) / (d + c * x)
 where,
 x – distance from the edge
 c – constant (UIScrollView uses 0.55)
 d – dimension, either width or height*/

static CGFloat rubberBandDistance(CGFloat offset, CGFloat dimension) {
    
    const CGFloat constant = 0.55f;
    CGFloat result = (constant * fabs(offset) * dimension) / (dimension + constant * fabs(offset));
    // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
    return offset < 0.0f ? -result : result;
}


@interface HJScrollViewAddDynamicViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *hScrollView;  // scroll in horizontal
@property (nonatomic, strong) UIScrollView *vScrollView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView *tableView;    // the current tabelView show in screen
@property (nonatomic, strong) NSMutableArray *tableArray; // store all the tabelViews we build
@property (nonatomic, strong) HJSegmentView *segmentView;
@property (nonatomic) BOOL isForbidScrollDelegate;
@property (nonatomic) BOOL vScrollViewEnabled;
@property (nonatomic) BOOL subScrollViewEnabled;
@property (nonatomic, assign) CGFloat currentPanY;
@property (nonatomic, assign) CGFloat currentScorllY;

//弹性和惯性动画
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIDynamicItemBehavior *decelerationBehavior;
@property (nonatomic, strong) LJDynamicItem *dynamicItem;
@property (nonatomic, weak) UIAttachmentBehavior *springBehavior;

@end

@implementation HJScrollViewAddDynamicViewController
{
    __block BOOL isVertical;//是否是垂直
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableArray = [NSMutableArray array];
    self.currentPanY = 0;
    [self setUIElemets];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.animator removeAllBehaviors];
}


- (void)panGes:(UIPanGestureRecognizer *)ges
{
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.currentScorllY = self.vScrollView.contentOffset.y;
            CGFloat currentY = [ges translationInView:self.view].y;
            CGFloat currentX = [ges translationInView:self.view].x;
            
            if (currentY == 0) {
                isVertical = NO;
            } else {
                if (fabs(currentX)/currentY >= 5.0) {
                    isVertical = NO;
                } else {
                    isVertical = YES;
                }
            }
            [self.animator removeAllBehaviors];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (isVertical) {
                //往上滑为负数，往下滑为正数
                CGFloat currentY = [ges translationInView:self.view].y;
                [self controlScrollForVertical:currentY AndState:UIGestureRecognizerStateChanged];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateEnded:
        {
            
            if (isVertical) {
                self.dynamicItem.center = self.view.bounds.origin;
                //velocity是在手势结束的时候获取的竖直方向的手势速度
                CGPoint velocity = [ges velocityInView:self.view];
                UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.dynamicItem]];
                [inertialBehavior addLinearVelocity:CGPointMake(0, velocity.y) forItem:self.dynamicItem];
                // 通过尝试取2.0比较像系统的效果
                inertialBehavior.resistance = 2.0;
                __block CGPoint lastCenter = CGPointZero;
                __weak typeof(self) weakSelf = self;
                inertialBehavior.action = ^{
                    if (isVertical) {
                        //得到每次移动的距离
                        CGFloat currentY = weakSelf.dynamicItem.center.y - lastCenter.y;
                        [weakSelf controlScrollForVertical:currentY AndState:UIGestureRecognizerStateEnded];
                    }
                    lastCenter = weakSelf.dynamicItem.center;
                };
                [self.animator addBehavior:inertialBehavior];
                self.decelerationBehavior = inertialBehavior;
            }
        }
            break;
        default:
            break;
    }
//    if (ges.state != UIGestureRecognizerStateChanged) {
//        self.currentPanY = 0;
//        self.vScrollViewEnabled = NO;
//        self.subScrollViewEnabled = NO;
//        NSLog(@"ges.state != UIGestureRecognizerStateChanged");
//    } else {
//        CGFloat currentY = [ges translationInView:self.vScrollView].y;
//        if (self.vScrollViewEnabled || self.subScrollViewEnabled) {
//            if (self.currentPanY == 0) {
//                self.currentPanY = currentY;   // 记录下临界点是 Y
//            }
//            NSLog(@"======================================== self.currentPanY = %f", self.currentPanY );
//            CGFloat offSetY = self.currentPanY - currentY; // 计算在临界点的 offsetY
//            NSLog(@"----------------------------------- offSetY = %f",offSetY);
//            if (self.vScrollViewEnabled) {
//                if ((HJTopViewHeight + offSetY) >= 0) {
//                    self.vScrollView.contentOffset = CGPointMake(0, HJTopViewHeight + offSetY);
//                } else {
//                    self.vScrollView.contentOffset = CGPointZero;
//                }
//            } else {
//                self.tableView.contentOffset = CGPointMake(0, offSetY);
//            }
//        }
//    }
}

//控制上下滚动的方法
- (void)controlScrollForVertical:(CGFloat)detal AndState:(UIGestureRecognizerState)state {
    //判断是主ScrollView滚动还是子ScrollView滚动,detal为手指移动的距离
    if (self.vScrollView.contentOffset.y >= HJTopViewHeight) {
        CGFloat offsetY = self.tableView.contentOffset.y - detal;
        if (offsetY < 0) {
            //当子ScrollView的contentOffset小于0之后就不再移动子ScrollView，而要移动主ScrollView
            offsetY = 0;
            self.vScrollView.contentOffset = CGPointMake(self.vScrollView.frame.origin.x, self.vScrollView.contentOffset.y - detal);
        } else if (offsetY > (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
            //当子ScrollView的contentOffset大于contentSize.height时
            
            offsetY = self.tableView.contentOffset.y - rubberBandDistance(detal, HJScreenHeight);
            //            offsetY = self.subTableView.contentSize.height - self.subTableView.frame.size.height;
            //            CGRect frame = self.mainScrollView.frame;
            //            frame.origin.y += rubberBandDistance(detal, height);
            //            self.mainScrollView.frame = frame;
        }
        self.tableView.contentOffset = CGPointMake(0, offsetY);
    } else {
        CGFloat mainOffsetY = self.vScrollView.contentOffset.y - detal;
        if (mainOffsetY < 0) {
            //滚到顶部之后继续往上滚动需要乘以一个小于1的系数
            //            mainOffsetY = 0;
            //            CGRect frame = self.mainScrollView.frame;
            //            frame.origin.y += rubberBandDistance(detal, height);
            //            self.mainScrollView.frame = frame;
            
            mainOffsetY = self.vScrollView.contentOffset.y - rubberBandDistance(detal, HJScreenHeight);
            
        } else if (mainOffsetY > HJTopViewHeight) {
            mainOffsetY = HJTopViewHeight;
        }
        self.vScrollView.contentOffset = CGPointMake(self.vScrollView.frame.origin.x, mainOffsetY);
        
        if (mainOffsetY == 0) {
            for (UITableView *tableView in self.tableArray) {
                tableView.contentOffset = CGPointMake(0, 0);
            }
        }
    }
    
    BOOL outsideFrame = self.vScrollView.contentOffset.y < 0 || self.tableView.contentOffset.y > (self.tableView.contentSize.height - self.tableView.frame.size.height);
    if (outsideFrame &&
        (self.decelerationBehavior && !self.springBehavior)) {
        
        CGPoint target = CGPointZero;
        BOOL isMian = NO;
        if (self.vScrollView.contentOffset.y < 0) {
            self.dynamicItem.center = self.vScrollView.contentOffset;
            target = CGPointZero;
            isMian = YES;
        } else if (self.tableView.contentOffset.y > (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
            self.dynamicItem.center = self.tableView.contentOffset;
            target = CGPointMake(self.tableView.contentOffset.x, (self.tableView.contentSize.height - self.tableView.frame.size.height));
            isMian = NO;
        }
        [self.animator removeBehavior:self.decelerationBehavior];
        __weak typeof(self) weakSelf = self;
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.dynamicItem attachedToAnchor:target];
        springBehavior.length = 0;
        springBehavior.damping = 1;
        springBehavior.frequency = 2;
        springBehavior.action = ^{
            if (isMian) {
                weakSelf.vScrollView.contentOffset = weakSelf.dynamicItem.center;
                if (weakSelf.vScrollView.contentOffset.y == 0) {
                    for (UITableView *tableView in self.tableArray) {
                        tableView.contentOffset = CGPointMake(0, 0);
                    }
                }
            } else {
                weakSelf.tableView.contentOffset = self.dynamicItem.center;
            }
        };
        [self.animator addBehavior:springBehavior];
        self.springBehavior = springBehavior;
    }
}


#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.hScrollView) {
        NSInteger index = scrollView.contentOffset.x/HJScreenWidth;
        self.tableView = self.tableArray[index];
        [self.segmentView setBottomViewContentOffset:CGPointMake(scrollView.contentOffset.x/5, 0)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    NSLog(@"=====================contentOffset y == %@", @(scrollView.contentOffset.y));
//    if (scrollView.tag == 999) {
//        if (scrollView.contentOffset.y > HJTopViewHeight) {
//            [self.vScrollView setContentOffset:CGPointMake(0, HJTopViewHeight)];
//            scrollView.scrollEnabled = NO;
//            self.vScrollViewEnabled = NO;
//            for (int i = 0; i < 5; i++) {
//                UITableView *tableV = self.tableArray[i];
//                tableV.scrollEnabled = YES;
//                self.subScrollViewEnabled = YES;
//                if (tableV.tag == self.tableView.tag) {
//                    [tableV setContentOffset:CGPointMake(0, scrollView.contentOffset.y - HJTopViewHeight) animated:false];
//                }
//            }
//        }
//        if (scrollView.contentOffset.y < 0) {
//            [self.vScrollView setContentOffset:CGPointZero animated:NO];
//        }
//    }
//    
//    if ([scrollView isKindOfClass:[UITableView class]] && scrollView.contentOffset.y < 0) {
//        for (int i = 0; i < 5; i++) {
//            UITableView *tableV = self.tableArray[i];
//            tableV.scrollEnabled = NO;
//            self.subScrollViewEnabled = NO;
//            if (tableV.tag != scrollView.tag) {
//                [tableV setContentOffset:CGPointZero animated:false];
//            }
//        }
//        self.vScrollView.scrollEnabled = YES;
//        self.vScrollViewEnabled = YES;
//        [self.vScrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y + self.vScrollView.contentOffset.y)];
//    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"测试:%ld", indexPath.row];
    return cell;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGFloat currentY = [recognizer translationInView:self.view].y;
        CGFloat currentX = [recognizer translationInView:self.view].x;
        //判断如果currentX为currentY的5倍及以上就是断定为横向滑动，返回YES，否则返货NO
        if (currentY == 0.0) {
            return YES;
        } else {
            if (fabs(currentX)/currentY >= 5.0) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}

#pragma mark -- UI

- (void)setUIElemets {
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.vScrollView];
    [self.vScrollView addSubview:self.hScrollView];
    [self.vScrollView addSubview:self.topView];
    self.subScrollViewEnabled = NO;
    self.vScrollViewEnabled = YES;
    
    // build tableVeiw with the given data, the number of the tableView completely decided by the data
    [self setTableViewsWith:5];
    self.segmentView = [HJSegmentView instanceWithFrame:CGRectMake(0, HJTopViewHeight, HJScreenWidth, HJSegmentViewH) withTitles:@[@"推荐", @"动漫", @"游戏", @"趣味", @"影视"] withClick:^(NSInteger index) {
        self.tableView = self.tableArray[index];
        self.hScrollView.contentOffset = CGPointMake( index * HJScreenWidth, 0);
        [self.segmentView setBottomViewContentOffset:CGPointMake(self.hScrollView.contentOffset.x/5, 0)];
    }];
    [_vScrollView addSubview:self.segmentView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.dynamicItem = [[LJDynamicItem alloc] init];
    
}

- (void)setTableViewsWith:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        UITableView *tableV = [self creatTableViewWithTag:i];
        [self.hScrollView addSubview:tableV];
        [self.tableArray addObject:tableV];
    }
    
    self.hScrollView.contentSize = CGSizeMake(HJScreenWidth * count, HJScreenHeight);
    self.tableView = self.tableArray[0];
}

- (UITableView *)creatTableViewWithTag:(NSInteger)tag {
    CGFloat offX = HJScreenWidth * tag;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(offX, 0, HJScreenWidth, HJScreenHeight)];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tag = tag;
    tableView.scrollEnabled = NO;
    return tableView;
}


#pragma mark -- lazy init

- (UIScrollView *)vScrollView {
    if (_vScrollView == nil) {
        _vScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, HJScreenWidth, HJScreenHeight)];
        _vScrollView.backgroundColor = [UIColor whiteColor];
        _vScrollView.showsVerticalScrollIndicator = NO;
        _vScrollView.contentSize = CGSizeMake(HJScreenWidth, HJScreenHeight + HJTopViewHeight);
        _vScrollView.tag = 999;
        _vScrollView.delegate = self;
        _vScrollView.scrollsToTop = NO;
    }
    return _vScrollView;
}

- (UIScrollView *)hScrollView {
    if (_hScrollView == nil) {
        _hScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, HJTopViewHeight + HJSegmentViewH, HJScreenWidth, HJScreenHeight + HJTopViewHeight)];
        _hScrollView.backgroundColor = [UIColor blueColor];
        _hScrollView.pagingEnabled = YES;
        _hScrollView.bounces = NO;
        _hScrollView.delegate = self;
    }
    return _hScrollView;
}

- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HJScreenWidth, HJTopViewHeight)];
        _topView.backgroundColor = [UIColor yellowColor];
    }
    return _topView;
}


@end
