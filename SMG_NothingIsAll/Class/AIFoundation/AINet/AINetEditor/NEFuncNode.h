//
//  NEFuncNode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NEElement.h"

@class NESingleNode;
@interface NEFuncNode : NEElement

+(id) newWithEId:(NSInteger)eId funcModel:(AIFuncModel*)funcModel funcClass:(Class)funcClass funcSel:(SEL)funcSel singleNode:(NESingleNode*)singleNode;

@end
