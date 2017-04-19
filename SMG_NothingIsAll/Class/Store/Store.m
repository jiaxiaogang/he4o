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
#import "LanguageHeader.h"

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
-(NSDictionary*) searchMemStoreWithLanguageText:(NSString*)text{
    NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(text),@"text", nil];
    return [self.memStore getSingleMemoryWithWhereDic:where];
}

-(NSMutableArray*) searchMemStoreContainerText:(NSString*)text limit:(NSInteger)limit{
    NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(text), @"text",nil];
    return [self.memStore getMemoryContainsWhereDic:where limit:limit];//习惯池;从记忆中搜索数量很多的存到习惯中...//随后添加分词系统的作用使这里更厉害;
}

@end
