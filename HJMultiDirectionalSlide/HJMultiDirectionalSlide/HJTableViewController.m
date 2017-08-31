//
//  HJTableViewController.m
//  HJMultiDirectionalSlide
//
//  Created by 黄静静 on 2017/8/18.
//  Copyright © 2017年 HJing. All rights reserved.
//  单个 scrollView 控制滑动交互

#import "HJTableViewController.h"
#import "HJSegmentView.h"
#import "HJTopView.h"
#import "MJRefresh.h"

@interface HJTableViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView1;
@property (nonatomic, strong) UITableView *tableView2;
@property (nonatomic, strong) HJTopView *topView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HJSegmentView *segmentView;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation HJTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self  buildUIElements];
}

- (void)buildUIElements {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = self.tableView1;
    [self.scrollView addSubview:self.tableView1];
    [self.scrollView addSubview:self.tableView2];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.topView];
    
    self.segmentView = [HJSegmentView instanceWithFrame:CGRectMake(0, 200 - 48, HJScreenWidth, 48) withTitles:@[@"跟我读", @"随便读"] withClick:^(NSInteger index) {
        if (index == 0) {
            self.tableView = self.tableView1;
        } else {
            self.tableView = self.tableView2;
        }
        self.scrollView.contentOffset = CGPointMake( index * HJScreenWidth, 0);
        [self.segmentView setBottomViewContentOffset:CGPointMake(self.scrollView.contentOffset.x/2, 0)];
    }];
    [self.topView addSubview:self.segmentView];
    
    __weak __typeof(self) weakSelf = self;
    self.tableView1.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 刷新操作
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView1.mj_header endRefreshing];
        });
    }];
    self.tableView1.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 加载更多
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView1.mj_footer endRefreshing];
        });
    }];
    
    self.tableView2.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 刷新操作
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView2.mj_header endRefreshing];
        });
    }];
    self.tableView2.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 加载更多
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView2.mj_footer endRefreshing];
        });
    }];
}

#pragma mark - scrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSInteger index = scrollView.contentOffset.x/HJScreenWidth;
        if (index == 0) {
            self.tableView = self.tableView1;
        } else {
            self.tableView = self.tableView2;
        }
        [self.segmentView setBottomViewContentOffset:CGPointMake(scrollView.contentOffset.x/2, 0)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UITableView class]]) {
        self.topView.frame = CGRectMake(0, 64 - scrollView.contentOffset.y, HJScreenWidth, 200);
        if (scrollView.tag == 1  && scrollView.contentOffset.y < (200 - 48)) {
            [self.tableView2 setContentOffset:CGPointMake(0, scrollView.contentOffset.y)];
        } else if (scrollView.tag == 2  && scrollView.contentOffset.y < (200 - 48)) {
            [self.tableView1 setContentOffset:CGPointMake(0, scrollView.contentOffset.y)];
        }
        if (scrollView.contentOffset.y > (200 - 48)) {
            self.topView.frame = CGRectMake(0, 64 - (200 - 48), HJScreenWidth, 200);
        }
    }
}

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

#pragma mark - TWPullTableView delegate

//- (void)fresh {
//    [self.tableView freshFinished];
//}
//
//- (void)moreData {
//    [self.tableView moreDataFinished];
//}

#pragma mark - Get
- (HJTopView *)topView{
    if (_topView == nil) {
        _topView = [[HJTopView alloc] initWithFrame:CGRectMake(0, 64, HJScreenWidth, 200)];
        _topView.backgroundColor = [UIColor yellowColor];
    }
    return _topView;
}

- (UITableView *)tableView1 {
    if (_tableView1 == nil) {
        _tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, HJScreenWidth, HJScreenHeight- 64)];
        _tableView1.backgroundColor = [UIColor whiteColor];
        _tableView1.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HJScreenWidth, 200)];
        _tableView1.delegate = self;
        _tableView1.dataSource = self;
//        _tableView1.TWDelegate = self;
        _tableView1.tag = 1;
    }
    return _tableView1;
}

- (UITableView *)tableView2 {
    if (_tableView2 == nil) {
        _tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(HJScreenWidth, 0, HJScreenWidth, HJScreenHeight - 64)];
        _tableView2.backgroundColor = [UIColor whiteColor];
        _tableView2.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HJScreenWidth, 200)];
        _tableView2.delegate = self;
        _tableView2.dataSource = self;
//        _tableView2.TWDelegate = self;
        _tableView2.tag = 2;
    }
    return _tableView2;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, HJScreenWidth, HJScreenHeight - 64)];
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(HJScreenWidth * 2, 0);
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.delegate = self;
    }
    return _scrollView;
}



@end
