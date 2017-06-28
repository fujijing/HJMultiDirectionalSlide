//
//  HJSlideViewController.m
//  HJMultiDirectionalSlide
//
//  Created by 黄静静 on 2017/6/27.
//  Copyright © 2017年 HJing. All rights reserved.
//

#import "HJSlideViewController.h"
#import "HJSegmentView.h"

#define HJScreenWidth [UIScreen mainScreen].bounds.size.width
#define HJScreenHeight [UIScreen mainScreen].bounds.size.height
#define HJTopViewHeight 200

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
    
    // build tableVeiw with the given data, the number of the tableView completely decided by the data
    [self setTableViewsWith:5];
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
}

- (void)setTableViewsWith:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        UITableView *tableV = [self creatTableViewWithTag:i];
        if (i % 2 == 0) {
            tableV.backgroundColor = [UIColor greenColor];
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

- (UIScrollView *)hScrollView {
    if (_hScrollView == nil) {
        _hScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, HJTopViewHeight, HJScreenWidth, HJScreenHeight + HJTopViewHeight)];
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
        _topView.backgroundColor = [UIColor redColor];
    }
    return _topView;
}

@end
