//
//  BaseTabBarViewController.m
//  funShow
//
//  Created by xiejinke on 16/7/20.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "BaseTabBarViewController.h"
#import "JokeViewController.h"
#import "AboutMeViewController.h"
#import "BaseNavigationViewController.h"
@interface BaseTabBarViewController ()

@end

@implementation BaseTabBarViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initVC];
    }
    return self;
}


- (void)initVC {
    JokeViewController *joke = [[JokeViewController alloc]init];
    BaseNavigationViewController *jokeNaVC = [[BaseNavigationViewController alloc]initWithRootViewController:joke];
    jokeNaVC.tabBarItem.title = @"joke";
    
    AboutMeViewController *about = [[AboutMeViewController alloc]init];
    BaseNavigationViewController *aboutNaVC = [[BaseNavigationViewController alloc]initWithRootViewController:about];
    aboutNaVC.tabBarItem.title = @"me";
    
    [self setViewControllers:@[jokeNaVC,aboutNaVC]];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
