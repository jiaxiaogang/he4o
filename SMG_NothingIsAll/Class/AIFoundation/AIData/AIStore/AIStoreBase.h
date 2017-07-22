//
//  AIStoreBase.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAIStore <NSObject>

+(id) searchSingleRowId:(NSInteger)rowId;
+(id) searchSingleWhere:(id)where;
+(NSMutableArray*) searchWhere:(id)where count:(NSInteger)count;
+(void) insert:(AIObject*)data awareness:(BOOL)awareness;

@end

@interface AIStoreBase : NSObject<IAIStore>

+(Class) getModelClass;

@end
