//
//  DDic.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/5/10.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "DDic.h"

@implementation DDic

-(NSMutableDictionary *)data {
    if (!_data) _data = [NSMutableDictionary new];
    return _data;
}

-(id) objectForKey:(id)key {
    return [self.data objectForKey:key];
}

-(id) objectV2ForKey1:(id)k1 k2:(id)k2 {
    DDic *v1 = [self.data objectForKey:k1];
    if (v1) return [v1 objectForKey:k2];
    return nil;
}

-(id) objectV3ForKey1:(id)k1 k2:(id)k2 k3:(id)k3 {
    DDic *v1 = [self.data objectForKey:k1];
    if (v1) {
        DDic *v2 = [v1 objectForKey:k2];
        if (v2) return [v2 objectForKey:k3];
    }
    return nil;
}

-(void) setObject:(id)value forKey:(id)key {
    [self.data setObject:value forKey:key];
}

-(void) setObjectV2:(id)v2 k1:(id)k1 k2:(id)k2 {
    DDic *v1 = [self.data objectForKey:k1];
    if (!v1) {
        v1 = [DDic new];
        [self setObject:v1 forKey:k1];
    }
    [v1 setObject:v2 forKey:k2];
}

-(void) setObjectV3:(id)v3 k1:(id)k1 k2:(id)k2 k3:(id)k3 {
    DDic *v1 = [self.data objectForKey:k1];
    if (!v1) {
        v1 = [DDic new];
        [self setObject:v1 forKey:k1];
    }
    DDic *v2 = [v1 objectForKey:k2];
    if (!v2) {
        v2 = [DDic new];
        [v1 setObject:v2 forKey:k2];
    }
    [v2 setObject:v3 forKey:k3];
}

@end
