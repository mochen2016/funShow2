//
//  AboutMeViewController.m
//  funShow
//
//  Created by xiejinke on 16/7/20.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "AboutMeViewController.h"
#import "DataBaseOpe.h"
#import "CommonDefine.h"
#import "LoginVC.h"
@interface AboutMeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation AboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"me";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    bool isLogin = [[NSUserDefaults standardUserDefaults]boolForKey:LoginStatus];
    if (!isLogin) {
        LoginVC *loginVC = [[LoginVC alloc]init];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }

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
