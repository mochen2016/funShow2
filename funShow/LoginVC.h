//
//  LoginVC.h
//  funShow
//
//  Created by xiejinke on 16/7/21.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "ViewController.h"

@interface LoginVC : ViewController

@property (nonatomic, copy) void(^loginCompletion)(NSDictionary *userInfo);

@property (nonatomic, copy) void(^resisterCompletion)(NSDictionary *userInfo);

@property (nonatomic, strong) NSString *type;

@end
