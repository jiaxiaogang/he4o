//
//  AITransferPort.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/16.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AITransferPort : NSObject

+(AITransferPort*) newWithScene:(AIKVPointer*)scene canset:(AIKVPointer*)canset;

@property (strong, nonatomic) AIKVPointer *scene;
@property (strong, nonatomic) AIKVPointer *canset;

@end
