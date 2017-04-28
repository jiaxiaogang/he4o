//
//  DataCell.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/28.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "DataCell.h"

@interface DataCell ()

@property (weak, nonatomic) IBOutlet UILabel *dataLab;
@property (strong,nonatomic) NSDictionary *dic;
@property (assign, nonatomic) StoreType storeType;

@end

@implementation DataCell


+ (NSString*)reuseIdentifier{
    return @"DataCell";
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

-(void) initView{
    
}


-(void) setData:(NSDictionary*)dic withStoreType:(StoreType)storeType{
    self.dic = dic;
    self.storeType = storeType;
    [self refreshDisplay];
}

-(void) refreshDisplay{
    if (self.dic) {
        if (self.storeType == StoreType_Mem) {
            [self.dataLab setText:@"记忆"];
        }else if (self.storeType == StoreType_Do) {
            [self.dataLab setText:@"行为"];
        }else if (self.storeType == StoreType_Obj) {
            [self.dataLab setText:@"实物"];
        }else if (self.storeType == StoreType_Text) {
            [self.dataLab setText:@"分词"];
        }else if (self.storeType == StoreType_Logic) {
            [self.dataLab setText:@"逻辑"];
        }
    }
}



+ (CGFloat) getCellHeight{
    return 64;
}

@end
