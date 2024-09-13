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

//MARK:===============================================================
//MARK:                     < 方便方法 >
//MARK:===============================================================

-(HEResult*) mkIsNew:(BOOL)isNew {
    return [self mk:@"isNew" v:@(isNew)];
}

-(HEResult*) mkData:(id)data {
    return [self mk:@"data" v:data];
}

-(BOOL) success {
    return NUMTOOK([self get:@"success"]).boolValue;
}
-(BOOL) isNew {
    return NUMTOOK([self get:@"isNew"]).boolValue;
}
-(id) data {
    return [self get:@"data"];
}

@end
