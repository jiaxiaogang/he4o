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
-(StoreModel_Text*) searchMemStoreWithLanguageText:(NSString*)text{
    for (StoreModel_Text *model in self.memStore.memArr) {
        if ([STRTOOK(text) isEqualToString:model.text]) {
            return model;
        }
    }
    return nil;
}

-(NSMutableArray*) searchMemStoreContainerText:(NSString*)text{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (StoreModel_Text *model in self.memStore.memArr) {
        if (model.text.length < 10 && [model.text containsString:STRTOOK(text)]) {//10个字以下的才模糊匹配;太长的句子模糊没意义//随后添加分词系统的作用使这里更厉害;
            [arr addObject:model];
        }
    }
    return arr;
}

-(NSMutableArray*) searchMemStoreContainerWord:(NSString*)word{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (StoreModel_Text *model in self.memStore.memArr) {//习惯池;
        if ([model.text containsString:STRTOOK(word)]) {//10个字以下的才模糊匹配;太长的句子模糊没意义//随后添加分词系统的作用使这里更厉害;
            [arr addObject:model];
        }
    }
    return arr;
}


@end
