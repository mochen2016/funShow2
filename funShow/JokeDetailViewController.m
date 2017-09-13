//
//  JokeDetailViewController.m
//  funShow
//
//  Created by xiejinke on 16/7/22.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "JokeDetailViewController.h"
#import "UIView+SDAutoLayout.h"
@implementation JokeDetailViewController
{
    UILabel *lbl_text;
}

- (instancetype)init {
    if (self == [super init]) {
        [self steup];
    }
    return self;
}

- (void)steup {
    lbl_text = [[UILabel alloc]init];
    lbl_text.textColor = [UIColor darkGrayColor];
    lbl_text.font = [UIFont systemFontOfSize:16];
    lbl_text.numberOfLines = 0;
    [self.view addSubview:lbl_text];
    
    CGFloat margin = 15;
    UIView *contentView = self.view;
    
    lbl_text.sd_layout
    .leftSpaceToView(contentView,margin)
    .topSpaceToView(contentView,margin + 64)
    .rightSpaceToView(contentView,margin)
    .autoHeightRatio(0);
    
}



- (void)setModel:(JokeInfo *)model {
    _model = model;
    NSString *text = [model.text stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    lbl_text.text = text;
    
}

- (void)dealloc
{
    NSLog(@"-------detail dealloc");
    
}

@end
