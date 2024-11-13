//
//  AITransferPort.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/16.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AITransferPort : NSObject <NSCoding>

+(AITransferPort*) newWithScene:(AIKVPointer*)selfCanset scene:(AIKVPointer*)scene canset:(AIKVPointer*)canset;

@property (strong, nonatomic) AIKVPointer *selfCanset;//因为迁移port是挂在scene下的,但与scene下的哪个canset有迁移关系呢?要么存成K字典,要么存成模型里的一个属性,这里就把这个canset存在这个模型里当属性了;
@property (strong, nonatomic) AIKVPointer *scene;
@property (strong, nonatomic) AIKVPointer *canset;

@end
