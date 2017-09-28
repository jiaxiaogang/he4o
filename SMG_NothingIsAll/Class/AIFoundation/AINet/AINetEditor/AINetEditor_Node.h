//
//  AINetEditor_Node.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/28.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < AINetEditor_Node >
//MARK:===============================================================
@interface AINetEditor_Node : NSObject

@property (strong,nonatomic) AINode *node;
@property (strong,nonatomic) NSString *eId;
+(id) newWithNode:(AINode*)node eId:(NSString*)eId;

@end
