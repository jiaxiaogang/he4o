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

/**
 *  MARK:--------------------指定ratio的评价重载--------------------
 *  @desc 旧有说明: 获取到cmvNode的评价力;
 *  @desc 对MC的评价时:
 *      1. 理性评价: 由MC匹配方法中,进行类比ms&cs&mcs决定;
 *      2. 感性评价: 由此处进行计算得出;
 *          如: 判断变脏后,不能吃; 参考17202表中示图 (被吃mv为负 (理性是间接的感性) (导致负价值))
 *          如: 判断cpu损坏,会浪费钱;
 *          如: 带皮坚果,不能吃, (根本,不能吃,比如坚果皮 (抽象为:吃皮,导致负mv))
 *
 *  @desc 对ExpOut评价时:
 *      1. 以默认ratio=0.2,进行评价;
 */
+(CGFloat) score4MV:(AIPointer*)cmvNode_p ratio:(CGFloat)ratio;
+(CGFloat) score4MV:(NSString*)algsType urgentTo_p:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p ratio:(CGFloat)ratio;
+(CGFloat) score4MV:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta ratio:(CGFloat)ratio;

@end
