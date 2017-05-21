//
//  LawModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------规律(同时)--------------------
 */
@class PointerModel;
@interface LawModel : NSObject

+ (LawModel*) initWithPointerModels:(PointerModel*)pModel,... ;
@property (strong,nonatomic) NSMutableArray *pointerArr;    //指针数组(存PointerModel)
@property (assign, nonatomic) NSInteger count;      //计数器


@end
