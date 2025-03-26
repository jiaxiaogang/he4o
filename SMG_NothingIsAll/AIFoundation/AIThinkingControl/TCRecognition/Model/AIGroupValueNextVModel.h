//
//  AIGroupValueNextVModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/26.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIGroupValueNextVModel : NSObject

@property (strong, nonatomic) NSDictionary *everyXYValidValue_ps;

//根据每一个单码识别到的组码结果，来判定：别的单码识别 的 有效范围。
-(NSDictionary*) reloadEveryXYValidValue_ps:(NSArray*)firstGV_ps;

-(NSArray*) getValidValue_ps:(NSInteger)x y:(NSInteger)y;

@end
