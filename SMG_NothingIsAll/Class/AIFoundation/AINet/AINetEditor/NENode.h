//
//  NENode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NEElement.h"


//MARK:===============================================================
//MARK:                     < AINetEditor_Node >
//MARK:===============================================================
@interface NENode : NEElement

@property (strong,nonatomic) AINode *node;
@property (strong,nonatomic) NSString *eId;
+(id) newWithNode:(AINode*)node eId:(NSString*)eId;

@end
