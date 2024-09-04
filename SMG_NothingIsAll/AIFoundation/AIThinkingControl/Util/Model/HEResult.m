//
//  HEResult.m
//  SMG_NothingIsAll
//
//  Created by jia on 04.09.2024.
//  Copyright © 2024 XiaoGang. All rights reserved.
//

#import "HEResult.h"

@implementation HEResult

+(HEResult*) newFailure {
    return [[[HEResult alloc] init] mk:@"success" v:@(0)];
}
+(HEResult*) newSuccess {
    return [[[HEResult alloc] init] mk:@"success" v:@(1)];
}

-(NSMutableDictionary *)dic {
    if (!_dic) _dic = [[NSMutableDictionary alloc] init];
    return _dic;
}

-(HEResult*) mk:(NSString*)k v:(id)v {
    [self.dic setObject:v forKey:k];
    return self;
}

-(id) get:(NSString*)k {
    return [self.dic objectForKey:k];
}

@end
