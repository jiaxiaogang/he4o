//
//  AIGroupValueNode.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/18.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIGroupValueNode.h"

@implementation AIGroupValueNode

//内容的md5值，特征以content_ps和level,x,y共同生成。
-(NSString*) getHeaderNotNull {
    if (!STRISOK(self.header)) self.header = [AINetUtils getGroupValueNodeHeader:self.content_ps];
    return self.header;
}

@end
