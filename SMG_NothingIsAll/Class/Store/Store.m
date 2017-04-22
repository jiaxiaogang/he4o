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
//精确匹配
-(NSDictionary*) searchMemStoreWithLanguageText:(NSString*)text{
    NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(text),@"text", nil];
    return [self.memStore getSingleMemoryWithWhereDic:where];
}

//包含匹配
-(NSMutableArray*) searchMemStoreContainerText:(NSString*)text limit:(NSInteger)limit{
    NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(text), @"text",nil];
    return [self.memStore getMemoryContainsWhereDic:where limit:limit];//习惯池;从记忆中搜索数量很多的存到习惯中...//随后添加分词系统的作用使这里更厉害;
}

//包含且智能去重匹配(ABBC=ABBC只取一个;ABBCD=ABB只取一个;*?ab*..参考windows搜索的方式;
//-(NSMutableArray*) searchMemStoreContainerText:(NSString*)text limit:(NSInteger)limit{
//    NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(text), @"text",nil];
//    return [self.memStore getMemoryContainsWhereDic:where limit:limit];//习惯池;从记忆中搜索数量很多的存到习惯中...//随后添加分词系统的作用使这里更厉害;
//}

@end
