//
//  AIMindValueModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/5.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMindValueModel.h"

@implementation AIMindValueModel

+(AIMindValueModel*) initWithType:(MindType)type value:(CGFloat)value {
    AIMindValueModel *mindV = [[AIMindValueModel alloc] init];//注!!!:随后添加去重处理;
    mindV.type = type;
    mindV.value = value;
    return mindV;
}

-(void)print{
    NSString *type;
    
    if (self.type == MindType_Hunger) {
        type = @"饥饿";
    }else if (self.type == MindType_Curiosity) {
        type = @"好奇心";
    }else if (self.type == MindType_Mood) {
        type = @"心情";
    }else if (self.type == MindType_Angry) {
        type = @"生气";
    }else if (self.type == MindType_Happy) {
        type = @"开心";
    }else if (self.type == MindType_Algesia) {
        type = @"痛觉";
    }
    
    NSLog(@"\n\
________________________________________\n\
                                       |\n\
<AIMindValueModel> :                   |\n\
rowid : %ld\n\
type : %@\n\
value : %f\n\
_______________________________________|\n\n\n",self.rowid,type,_value);

}

@end
