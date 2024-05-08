//
//  AITransferModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/5/18.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------canset与scene对应模型--------------------
 *      2023.05.18: 随着迁移执行,canset与scene改为对应模型结果,避免后面更新eff+1时对应错 (参考29095-修复);
 */
@interface AITransferModel : NSObject <NSCoding>

+(AITransferModel*) newWithCansetTo:(AIKVPointer*)canset;

//@property (strong, nonatomic) AIKVPointer *scene;
@property (strong, nonatomic) AIKVPointer *canset;

@end
