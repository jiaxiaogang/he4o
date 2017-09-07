//
//  LawModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "LawModel.h"

@implementation LawModel

/**
 *  MARK:--------------------初始化规律类--------------------
 */

+ (LawModel*) initWithAIPointers:(AIPointer*)pModel,... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead"){
    LawModel *lModel = [[LawModel alloc] init];
    lModel.pointerArr = [[NSMutableArray alloc] init];
    
    //使用va_list定义一个argList指针变量，该指针变量指向可变参数列表
    va_list argList;
    if (pModel && [pModel isMemberOfClass:[AIPointer class]]) {
        [lModel.pointerArr addObject:pModel];
        
        //让argList指向第一个可变参数列表的第一个参数
        va_start(argList, pModel);
        //va_arg用于提取argList指针当前指向的参数，并将指针移动到指向下一个参数(arg变量用于保存当前获取的参数)
        AIPointer* arg = va_arg(argList, id);
        while (arg && [arg isMemberOfClass:[AIPointer class]]) {
            [lModel.pointerArr addObject:arg];
            //再次提取下一个参数，并将指针移动到下一个参数
            arg = va_arg(argList, id);
        }
        va_end(argList);
    }
    return lModel;
}

/**
 *  MARK:--------------------初始化规律类--------------------
 *  注:model...必须是已在数据库中的数据
 */
+ (LawModel*) initWithModels:(NSObject*)model,...  NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead"){
    LawModel *lModel = [[LawModel alloc] init];
    lModel.pointerArr = [[NSMutableArray alloc] init];
    
    va_list argList;
    if (model) {
        [lModel.pointerArr addObject:[AISqlPointer initWithClass:model.class withId:model.rowid]];
        
        va_start(argList, model);
        NSObject* arg = va_arg(argList, id);
        while (arg) {
            [lModel.pointerArr addObject:[AISqlPointer initWithClass:arg.class withId:arg.rowid]];
            arg = va_arg(argList, id);
        }
        va_end(argList);
    }
    return lModel;
}

- (void) print{
    NSLog(@"------------打印Law数据\n");
    if (ARRISOK(self.pointerArr)) {
        for (NSInteger i = 0; i < self.pointerArr.count; i++) {
            AIPointer *pModel = self.pointerArr[i];
            NSLog(@"___%ld___(%@)\n",i,pModel.class);
            NSLog(@"___%ld___(rowid:%ld)\n",i,(long)pModel.rowid);
            NSLog(@"___%ld___(pId:%ld)\n\n",i,(long)pModel.pointerId);
        }
    }
    NSLog(@"------------end\n\n");
}


@end
