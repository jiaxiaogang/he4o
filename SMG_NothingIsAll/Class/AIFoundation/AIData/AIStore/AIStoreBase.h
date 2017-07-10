//
//  AIStoreBase.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAIStore <NSObject>

+(id) search;
+(void) insert:(id)data;

@end

@interface AIStoreBase : NSObject<IAIStore>

@end
