//
//  DDic.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/5/10.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "DDic.h"

@implementation DDic

-(NSMutableDictionary *)v1 {
    if (!_v1) _v1 = [NSMutableDictionary new];
    return _v1;
}

-(id) objectForKey1:(id)k1 k2:(id)k2 {
    NSMutableDictionary *v1 = [self.v1 objectForKey:k1];
    if (v1) return [v1 objectForKey:k2];
    return nil;
}

-(void) setObject:(id)v2 forKey1:(id)k1 k2:(id)k2 {
    NSMutableDictionary *v1 = [self.v1 objectForKey:k1];
    if (!v1) {
        v1 = [NSMutableDictionary new];
        [self.v1 setObject:v1 forKey:k1];
    }
    [v1 setObject:v2 forKey:k2];
}

@end
