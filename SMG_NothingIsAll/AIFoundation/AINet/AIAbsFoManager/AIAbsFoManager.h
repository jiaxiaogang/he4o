//
//  AIAbsFoManager.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < AINetAbs管理器 >
//MARK:===============================================================
@class AINetAbsFoNode,AIFoNodeBase;
@interface AIAbsFoManager : NSObject

/**
 *  MARK:--------------------构建fo_防重版--------------------
 *  @param difStrong : 构建fo的被引用初始强度;
 */
-(HEResult*) create_NoRepeat:(NSArray*)content_ps protoFo:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo difStrong:(NSInteger)difStrong type:(AnalogyType)type protoIndexDic:(NSDictionary*)protoIndexDic assIndexDic:(NSDictionary*)assIndexDic outConAbsIsRelate:(BOOL*)outConAbsIsRelate noRepeatArea_ps:(NSArray*)noRepeatArea_ps;

@end
