//
//  XGRedisDictionary.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "XGRedisDictionary.h"
#import "XGRedisUtil.h"

@interface XGRedisDictionary()

@property (strong, nonatomic) NSMutableArray *keys;
@property (strong, nonatomic) NSMutableArray *values;

@end


@implementation XGRedisDictionary

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    _keys = [[NSMutableArray alloc] init];
    _values = [[NSMutableArray alloc] init];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(NSArray*) allKeys{
    return [self.keys copy];
}

-(NSInteger) count{
    return self.keys.count;
}

-(BOOL) removeObjectAtIndex:(NSInteger)index{
    if (index >= 0 && index < self.count) {
        [self.keys removeObjectAtIndex:index];
        [self.values removeObjectAtIndex:index];
        return true;
    }
    return false;
}

//add
-(BOOL) addObject:(NSObject*)obj forKey:(NSString*)key{
    if (obj && STRISOK(key)) {
        [self.keys addObject:key];
        [self.values addObject:obj];
        return true;
    }
    return false;
}

//insert
-(BOOL) insertObject:(NSObject*)obj key:(NSString*)key atIndex:(NSInteger)index{
    if (index < self.count && obj && STRISOK(key)) {
        [self.keys insertObject:key atIndex:index];
        [self.values insertObject:obj atIndex:index];
        return true;
    }
    return false;
}

-(NSString*) keyForIndex:(NSInteger)index{
    return ARR_INDEX(self.keys, index);
}

-(NSObject*) valueForIndex:(NSInteger)index{
    return ARR_INDEX(self.values, index);
}

@end



//MARK:===============================================================
//MARK:                     < 回收模型 >
//MARK:===============================================================
@implementation XGRedisGCMark

@end
