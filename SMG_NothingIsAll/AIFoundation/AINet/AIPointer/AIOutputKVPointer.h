//
//  AIAlgsPointer.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/1/28.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

/**
 *  MARK:--------------------output记录数据的指针--------------------
 *  1. 根据此指针,可以直接调用到指定输出算法,并将指针下的内容输出;
 *  2. 输出指针可直接
 */
@interface AIOutputKVPointer : AIPointer

+(AIOutputKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName algsType:(NSString*)algsType dataTo:(NSString*)dataTo;
-(NSString*) folderName;//神经网络根目录 | 索引根目录
-(NSString*) algsType;  //输出算法类型_分区
-(NSString*) dataTo;    //输出算法函数名

@end
