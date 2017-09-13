//
//  JokeTableViewCell.m
//  funShow
//
//  Created by xiejinke on 16/7/21.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "JokeTableViewCell.h"
#import "UIView+SDAutoLayout.h"
@implementation JokeTableViewCell

{
    UILabel *_textLabel;
    UILabel *_timeLabel;
    UILabel *_titleLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _textLabel = [UILabel new];
    [self.contentView addSubview:_textLabel];
    _textLabel.textColor = [UIColor darkGrayColor];
    _textLabel.font = [UIFont systemFontOfSize:16];
    _textLabel.numberOfLines = 0;
    
    _timeLabel = [UILabel new];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textColor = [UIColor grayColor];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.numberOfLines = 0;
    
    
    
    _titleLabel = [UILabel new];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.numberOfLines = 0;
    
    
    CGFloat margin = 15;
    UIView *contentView = self.contentView;
    
    _titleLabel.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(contentView, margin)
    .rightSpaceToView(contentView, margin)
    .autoHeightRatio(0);
    
    _timeLabel.sd_layout
    .leftSpaceToView(contentView,margin)
    .topSpaceToView(_titleLabel,margin)
    .rightSpaceToView(contentView,margin)
    .autoHeightRatio(0);
    
    _textLabel.sd_layout
    .leftSpaceToView(contentView,margin)
    .topSpaceToView(_timeLabel,margin)
    .rightSpaceToView(contentView,margin)
    .autoHeightRatio(0)
    .maxHeightIs(150);
    
    // 当你不确定哪个view在自动布局之后会排布在cell最下方的时候可以调用次方法将所有可能在最下方的view都传过去
    [self setupAutoHeightWithBottomViewsArray:@[_timeLabel,_titleLabel, _textLabel] bottomMargin:margin];
}

- (void)setModel:(JokeInfo *)model
{
    _model = model;
    
    
    NSString *time = model.ct;
    if (time && time.length > 19) {
        time = [time substringToIndex:19];
    }
    _timeLabel.text = time;
    
    _titleLabel.text = model.title;
    
    NSString *text = [model.text stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    _textLabel.text = text;
    
}


@end
