//
//  TmpDic.m
//  SMG_NothingIsAll
//
//  Created by jia on 26.06.2024.
//  Copyright © 2024 XiaoGang. All rights reserved.
//

#import "TmpDic.h"

@implementation TmpDic

-(instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    self = [super init];
    if (self) {
        //[self setDictionary:otherDictionary];
        
        for (id k in otherDictionary.allKeys) {
            id v = [otherDictionary objectForKey:k];
            [super setObject:v forKey:k];
        }
    }
    return self;
}

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [super setObject:anObject forKey:aKey];
}

@end
