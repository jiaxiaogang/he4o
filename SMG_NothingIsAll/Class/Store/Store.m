//
//  Store.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Store.h"
#import "SMGHeader.h"

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

-(NSArray*) searchMemStoreContainerText:(NSString*)text{
    self.memStore.dic 
}

@end
