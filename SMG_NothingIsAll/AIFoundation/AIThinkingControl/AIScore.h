//
//  AIScore.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/5.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 评价器 >
//MARK: 从最初版本开始,已经支持评价器,只是一直未整理,此类将各评价器整理进来,分以下几种 (参考n22p1):
//MARK: 1. 感性评价 (反思)
//MARK:     > FPS & MPS
//MARK: 2. 理性评价 (反省)
//MARK:     > VRS & ARS & FRS
//MARK:===============================================================
@class AIShortMatchModel,TOFoModel;
@interface AIScore : NSObject

+(BOOL) VRS:(AIKVPointer*)value_p sPorts:(NSArray*)sPorts pPorts:(NSArray*)pPorts;
+(BOOL) FRS:(AIFoNodeBase*)fo;
+(BOOL) FPS:(TOFoModel*)outModel rtBlock:(AIShortMatchModel*(^)(void))rtBlock;
//+(BOOL) ARS;//ARS在MIsC判定成功后,由PM实现,PM涉及代码较多,先不迁移过来;

@end
