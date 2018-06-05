//
//  AINetAbsIndex.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/6/5.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 宏信息索引 >
//MARK:===============================================================
@class AIKVPointer,AINetAbsNode;
@interface AINetAbsIndex : NSObject

//创建absNode前,要先查是否已存在;
-(AIKVPointer*) getAbsPointer:(NSArray*)refs_p;

//创建absNode后,要建索引;
-(void) setAbsNode:(AINetAbsNode*)absNode;

@end
