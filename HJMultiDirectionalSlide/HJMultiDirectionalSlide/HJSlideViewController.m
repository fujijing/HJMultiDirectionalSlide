//
//  HJSlideViewController.m
//  HJMultiDirectionalSlide
//
//  Created by 黄静静 on 2017/6/27.
//  Copyright © 2017年 HJing. All rights reserved.
//

#import "HJSlideViewController.h"
#import "HJSegmentView.h"

#define HJTopViewHeight 200
#define HJSegmentViewH  50

@interface HJSlideViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *hScrollView;  // scroll in horizontal
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView *tableView;    // the current tabelView show in screen
@property (nonatomic, strong) NSMutableArray *tableArray; // store all the tabelViews we build
@property (nonatomic, strong) HJSegmentView *segmentView;
@end

@implementation HJSlideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableArray = [NSMutableArray array];
    
    [self setUIElemets];
}

#pragma mark -- UIScrollViewDelegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.hScrollView) {
        
        [self.segmentView setBottomViewContentOffset:CGPointMake(scrollView.contentOffset.x/5, 0)];
//        NSLog(@"=====================contentOffset x == %@", @(scrollView.contentOffset.x));
    }
}

#pragma mark -- UI

- (void)setUIElemets {
    self.view.backgroundColor = [UIColor whiteColor];
    UIScrollView *vScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, HJScreenWidth, HJScreenHeight)];
    vScrollView.backgroundColor = [UIColor whiteColor];
    vScrollView.showsVerticalScrollIndicator = NO;
    vScrollView.contentSize = CGSizeMake(HJScreenWidth, HJScreenHeight + HJTopViewHeight);
    vScrollView.tag = 999;
    vScrollView.delegate = self;
    vScrollView.scrollsToTop = NO;
//    vScrollView.bounces = NO;
    [vScrollView addSubview:self.hScrollView];
    
    [vScrollView addSubview:self.topView];
    
    [self.view addSubview:vScrollView];
    
    // build tableVeiw with the given data, the number of the tableView completely decided by the data
    [self setTableViewsWith:8];
    self.segmentView = [HJSegmentView instanceWithFrame:CGRectMake(0, HJTopViewHeight, HJScreenWidth, HJSegmentViewH) withTitles:@[@"推荐", @"动漫", @"游戏", @"趣味", @"影视", @"生活", @"音乐", @"焦点"] withClick:^(NSInteger index) {
        self.hScrollView.contentOffset = CGPointMake( index * HJScreenWidth, 0);
    }];
    [vScrollView addSubview:self.segmentView];
}

- (void)setTableViewsWith:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        UITableView *tableV = [self creatTableViewWithTag:i];
        if (i % 2 == 0) {
            tableV.backgroundColor = [UIColor whiteColor];
        } else tableV.backgroundColor = [UIColor yellowColor];
        [self.hScrollView addSubview:tableV];
        [self.tableArray addObject:tableV];
    }
    
    self.hScrollView.contentSize = CGSizeMake(HJScreenWidth * count, HJScreenHeight);
    self.tableView = self.tableArray[0];
}

- (UITableView *)creatTableViewWithTag:(NSInteger)tag {
    CGFloat offX = HJScreenWidth * tag;
    UITableView *tabelView = [[UITableView alloc] initWithFrame:CGRectMake(offX, 0, HJScreenWidth, HJScreenHeight)];
    tabelView.backgroundColor = [UIColor whiteColor];
    tabelView.separatorStyle = UITableViewCellSelectionStyleNone;
    tabelView.scrollsToTop = YES;
    tabelView.tag = tag;
    tabelView.scrollEnabled = NO;
    return tabelView;
}


#pragma mark -- lazy init

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
