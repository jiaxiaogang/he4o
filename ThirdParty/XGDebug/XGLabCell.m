//
//  XGLabCell.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/4/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "XGLabCell.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface XGLabCell ()

@property (strong, nonatomic) UILabel *lab;

@end

@implementation XGLabCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void) setText:(NSString*)text color:(UIColor*)color font:(CGFloat)font{
    if (!self.lab) {
        self.lab = [[UILabel alloc] init];
        [self addSubview:self.lab];
        [self.lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_offset(3).mas_equalTo(self);
            make.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self);
        }];
    }
    if (font > 0) {
        [self.lab setFont:[UIFont systemFontOfSize:font]];
    }
    if (color) {
        [self.lab setTextColor:color];
    }
    self.lab.text = text;
}

@end
