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
-(AINetAbsFoNode*) create_NoRepeat:(NSArray*)conFos content_ps:(NSArray*)content_ps difStrong:(NSInteger)difStrong at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type;

@end
