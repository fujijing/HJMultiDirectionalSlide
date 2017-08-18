//
//  HJScrollViewController.m
//  HJMultiDirectionalSlide
//
//  Created by 黄静静 on 2017/8/18.
//  Copyright © 2017年 HJing. All rights reserved.
//

#import "HJScrollViewController.h"
#import "HJSegmentView.h"

#define HJTopViewHeight 200
#define HJSegmentViewH  50

@interface HJScrollViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
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
@end

@implementation HJScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableArray = [NSMutableArray array];
    self.currentPanY = 0;
    [self setUIElemets];
}

- (void)panGes:(UIPanGestureRecognizer *)ges
{
    if (ges.state != UIGestureRecognizerStateChanged) {
        self.currentPanY = 0;
        self.vScrollViewEnabled = NO;
        self.subScrollViewEnabled = NO;
    } else {
        CGFloat currentY = [ges translationInView:self.vScrollView].y;
        
        if (self.vScrollViewEnabled || self.subScrollViewEnabled) {
            if (self.currentPanY == 0) {
                self.currentPanY = currentY;   // 记录下临界点是 Y
            }
            NSLog(@"**************************** currentY = %f", self.currentPanY );
            CGFloat offSetY = self.currentPanY - currentY; // 计算在临界点的 offsetY
            NSLog(@"----------------------------------- offSetY = %f",offSetY);
            if (self.vScrollViewEnabled) {
                if ((HJTopViewHeight + offSetY) >= 0) {
                    self.vScrollView.contentOffset = CGPointMake(0, HJTopViewHeight + offSetY);
                } else {
                    self.vScrollView.contentOffset = CGPointZero;
                }
            } else {
                self.tableView.contentOffset = CGPointMake(0, offSetY);
            }
        }
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
    if (scrollView.tag == 999) {
        if (scrollView.contentOffset.y > 200) {
            NSLog(@"=====================contentOffset y == %@", @(scrollView.contentOffset.y));
            scrollView.scrollEnabled = NO;
            self.vScrollViewEnabled = NO;
            for (int i = 0; i < 5; i++) {
                UITableView *tableV = self.tableArray[i];
                tableV.scrollEnabled = YES;
                self.subScrollViewEnabled = YES;
            }
            //            [self.vScrollView setContentOffset:CGPointMake(0, HJTopViewHeight) animated:false];
        }
        
        if (scrollView.contentOffset.y < 0) {
            [self.vScrollView setContentOffset:CGPointZero animated:NO];
        }
    }
    
    if ([scrollView isKindOfClass:[UITableView class]] && scrollView.contentOffset.y < 0) {
        for (int i = 0; i < 5; i++) {
            UITableView *tableV = self.tableArray[i];
            tableV.scrollEnabled = NO;
            self.subScrollViewEnabled = NO;
            if (tableV.tag != scrollView.tag) {
                [tableV setContentOffset:CGPointZero animated:false];
            }
        }
        self.vScrollView.scrollEnabled = YES;
        self.vScrollViewEnabled = YES;
        [self.vScrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y + self.vScrollView.contentOffset.y)];
    }
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
    return YES;
}

#pragma mark -- UI

- (void)setUIElemets {
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    }];
    [_vScrollView addSubview:self.segmentView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
    pan.delegate = self;
    [self.vScrollView addGestureRecognizer:pan];
    
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
