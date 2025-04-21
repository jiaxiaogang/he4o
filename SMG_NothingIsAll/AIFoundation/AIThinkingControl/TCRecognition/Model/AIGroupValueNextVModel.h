//
//  AIGroupValueNextVModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/26.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//2025.03.26: 先关掉，因为reload的性能太差了，也没时间优化它，感觉还是组码识别的循环数太多，再优化也得最终回到那儿去，先搞循环优化，再搞这些小技巧锦上添花。
#define Switch4NextVModel false

@interface AIGroupValueNextVModel : NSObject

@property (strong, nonatomic) NSDictionary *everyXYValidValue_ps;

-(NSArray*) getValidValue_ps:(NSInteger)x y:(NSInteger)y;

@end
