//
//  Store.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Store.h"
#import "SMGHeader.h"
#import "StoreHeader.h"

@implementation Store

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.memStore = [[MemStore alloc] init];
    self.mkStore = [[MKStore alloc] init];
}

/**
 *  MARK:--------------------搜索关于文字的记忆--------------------
 */
-(LanguageStoreModel*) searchMemStoreWithLanguageText:(NSString*)text{
    return [self.memStore.dic objectForKey:STRTOOK(text)];
}

-(NSMutableArray*) searchMemStoreContainerText:(NSString*)text{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSString *key in self.memStore.dic.allKeys) {
        if (key.length < 10 && [key containsString:STRTOOK(text)]) {//10个字以下的才模糊匹配;太长的句子模糊没意义
            [arr addObject:[self.memStore.dic objectForKey:key]];
        }
    }
    return arr;
}

@end
