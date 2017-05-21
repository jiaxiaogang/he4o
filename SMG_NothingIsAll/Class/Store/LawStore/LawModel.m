//
//  LawModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "LawModel.h"

@implementation LawModel

+ (LawModel*) initWithPointerModels:(PointerModel*)pModel,... {
    LawModel *lModel = [[LawModel alloc] init];
    lModel.pointerArr = [[NSMutableArray alloc] init];
    
    //使用va_list定义一个argList指针变量，该指针变量指向可变参数列表
    va_list argList;
    if (pModel && [pModel isMemberOfClass:[PointerModel class]]) {
        [lModel.pointerArr addObject:pModel];
        
        //让argList指向第一个可变参数列表的第一个参数
        va_start(argList, pModel);
        //va_arg用于提取argList指针当前指向的参数，并将指针移动到指向下一个参数(arg变量用于保存当前获取的参数)
        PointerModel* arg = va_arg(argList, id);
        while (arg && [arg isMemberOfClass:[PointerModel class]]) {
            [lModel.pointerArr addObject:arg];
            //再次提取下一个参数，并将指针移动到下一个参数
            arg = va_arg(argList, id);
        }
        va_end(argList);
    }
    return lModel;
}

@end
