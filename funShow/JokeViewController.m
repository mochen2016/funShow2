//
//  JokeViewController.m
//  funShow
//
//  Created by xiejinke on 16/7/20.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "JokeViewController.h"
#import "ServerDataOpe.h"
#import "DataBaseOpe.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "JokeTableViewCell.h"
#import "JokeInfo.h"
#import "SDRefresh.h"
#import "JokeDetailViewController.h"
#import "Authentication.h"
@interface JokeViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger allNum;
    NSInteger allPages;
    NSInteger currentPage;
    NSInteger maxResult;
    NSInteger ret_code;

    
    SDRefreshHeaderView *_refreshHeader;
    SDRefreshFooterView *_refreshFooter;
    
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation JokeViewController

- (void)authentication {
    void(^showAlert)(NSString *msg) = ^(NSString *msg){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        });
    };
    
    [Authentication authenticateUserLocalizedReason:@"按上你的指纹" completionSuccess:^{
        showAlert(@"验证成功");
    } error:^(NSError *error) {
        showAlert(@"指纹验证失败");
    } notCanEvaluatePolicy:^(NSError *error) {
        showAlert(@"设备不支持指纹");
    }];
    
}

-(UIImage *)imageWithBgColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//        });
//    });

    [self.navigationController.navigationBar setBackgroundImage:[self imageWithBgColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setShadowImage:[self imageWithBgColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]]];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"authen" style:UIBarButtonItemStyleDone target:self action:@selector(authentication)];;
    self.navigationItem.title = @"Joke";
    _dataArray = [NSMutableArray array];
    [self.view addSubview:self.tableView];
    /*
    __weak typeof(self) weakself = self;
    
    [DataBaseOpe getJokeCompletion:^(NSArray *jokes) {
        [weakself reload:jokes.mutableCopy];
        
        [weakself getJokeDataByPage:1 isRefresh:YES completion:nil];
    }];
    
    
    
    //下拉刷新
    _refreshHeader = [SDRefreshHeaderView refreshView];
    [_refreshHeader addToScrollView:self.tableView];
    __weak typeof(_refreshHeader) weakResreshHeader = _refreshHeader;
    _refreshHeader.beginRefreshingOperation = ^() {
        [weakself getJokeDataByPage:1 isRefresh:YES completion:^{
            [weakResreshHeader endRefreshing];
        }];
    };

    
    // 上拉加载
    _refreshFooter = [SDRefreshFooterView refreshView];
    [_refreshFooter addToScrollView:self.tableView];
    __weak typeof(_refreshFooter) weakRefreshFooter = _refreshFooter;
    _refreshFooter.beginRefreshingOperation = ^() {
        [weakself getJokeDataByPage:1+currentPage isRefresh:NO completion:^{
            [weakRefreshFooter endRefreshing];
        }];
    };
    */
    
    
}

- (void)getJokeDataByPage:(NSInteger)page isRefresh:(BOOL)refresh completion:(void(^)())completion {
    page = page > allPages ? 1 : page;
    __weak typeof(self) weakself = self;
    [ServerDataOpe getJokeDataByPage:(int)page isRefresh:refresh withBlock:^(NSDictionary *data) {
        NSLog(@"%@",data);
        allNum = [data[@"allNum"] integerValue];
        allPages = [data[@"allPages"] integerValue];
        currentPage = [data[@"currentPage"] integerValue];
        maxResult = [data[@"maxResult"] integerValue];
        ret_code = [data[@"ret_code"] integerValue];
        
        [DataBaseOpe getJokeCompletion:^(NSArray *jokes) {
            [weakself.dataArray removeAllObjects];
            
            [weakself reload:jokes.mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion();
                }
            });
            
        }];
    }];
}

- (void)reload:(NSMutableArray *)arr {
    __weak typeof(self) weakself = self;
    
    [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult result = [[obj1 valueForKey:@"ct"] compare:[obj2 valueForKey:@"ct"]];
        switch (result) {
            case NSOrderedSame:
                return result;
                break;
            case NSOrderedDescending:
                return NSOrderedAscending;
                break;
            case NSOrderedAscending:
                return NSOrderedDescending;
                break;
        }
        
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.dataArray addObjectsFromArray:arr];
        [weakself.tableView reloadData];
    });
}

#pragma mark - get

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return _dataArray.count;
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
//    JokeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
//        cell = [[JokeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
//    cell.model = self.dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"NO.%d",indexPath.row+1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    JokeInfo * model = self.dataArray[indexPath.row];
//    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[JokeTableViewCell class] contentViewWidth:[UIScreen mainScreen].bounds.size.width];
    return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
//    JokeInfo * model = self.dataArray[indexPath.row];
//    
//    JokeDetailViewController *detail = [[JokeDetailViewController alloc]init];
//    detail.hidesBottomBarWhenPushed = YES;
//    detail.model = model;
//    [self.navigationController pushViewController:detail animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
     [self.navigationController.navigationBar setBackgroundImage:[self imageWithBgColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:self.tableView.contentOffset.y / 100]] forBarMetrics:UIBarMetricsDefault];
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
