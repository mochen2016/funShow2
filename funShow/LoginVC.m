//
//  LoginVC.m
//  funShow
//
//  Created by xiejinke on 16/7/21.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "LoginVC.h"
#import "UIView+SDAutoLayout.h"
#import "CommonDefine.h"
@interface LoginVC ()
@property (nonatomic, strong) UITextField *tf_name;
@property (nonatomic, strong) UITextField *tf_pw;
@property (nonatomic, strong) UIButton *btn_ok;
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _type = @"Login";
    
    [self.view addSubview:self.tf_name];
    [self.view addSubview:self.tf_pw];
    [self.view addSubview:self.btn_ok];
    [self setup];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Register" style:UIBarButtonItemStylePlain target:self action:@selector(registerUser:)];
    
    
}


- (void)setup {
    
    CGFloat space = 20;
    CGFloat height = 45;
    _tf_name.sd_layout.leftSpaceToView(self.view,space)
    .rightSpaceToView(self.view,space)
    .centerXIs(self.view.center.x)
    .topSpaceToView(self.view,100)
    .heightIs(height);
    
    _tf_pw.sd_layout.leftSpaceToView(self.view,space)
    .rightSpaceToView(self.view,space)
    .centerXIs(self.view.center.x)
    .topSpaceToView(_tf_name,space)
    .heightIs(height);
    
    
    _btn_ok.sd_layout.leftSpaceToView(self.view,space)
    .rightSpaceToView(self.view,space)
    .centerXIs(self.view.center.x)
    .topSpaceToView(_tf_pw,space)
    .heightIs(height);
}


- (UITextField *)tf_name {
    if (!_tf_name) {
        _tf_name = [[UITextField alloc]init];
        _tf_name.placeholder = @"name";
        _tf_name.textColor = [UIColor darkGrayColor];
        _tf_name.borderStyle = UITextBorderStyleBezel;
    }
    
    return _tf_name;
}

- (UITextField *)tf_pw{
    if (!_tf_pw) {
        _tf_pw = [[UITextField alloc]init];
        _tf_pw.placeholder = @"password";
        _tf_pw.textColor = [UIColor darkGrayColor];
        _tf_pw.borderStyle = UITextBorderStyleBezel;
        _tf_pw.secureTextEntry = YES;
    }
    
    return _tf_pw;
}


- (UIButton *)btn_ok {
    if (!_btn_ok) {
        _btn_ok = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn_ok.backgroundColor = RGB(0, 151.0, 224.0);
        [_btn_ok setTitle:_type forState:UIControlStateNormal];
        
        [_btn_ok addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btn_ok;
}

- (void)btnAction:(UIButton *)btn {
    NSDictionary *user = @{@"uid":@(arc4random()),@"name":_tf_name.text,@"pw":_tf_pw.text};
    if ([btn.currentTitle isEqualToString:@"Login"]) {
        if (_loginCompletion) {
            _loginCompletion(user);
        }
    }else {
        if (_resisterCompletion) {
            _resisterCompletion(user);
        }
    }
}

- (void)registerUser:(UIBarButtonItem *)btn {
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Login"]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"Register"];
        [_btn_ok setTitle:@"Login" forState:UIControlStateNormal];
    }else {
        [self.navigationItem.rightBarButtonItem setTitle:@"Login"];
        [_btn_ok setTitle:@"Register" forState:UIControlStateNormal];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
