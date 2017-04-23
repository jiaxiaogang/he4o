//
//  MKStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MKStore.h"
#import "TMCache.h"
#import "SMGHeader.h"
#import "StoreHeader.h"

@interface MKStore ()

@property (strong,nonatomic) TextStore *textStore;       //字符串 处理能力

@end

@implementation MKStore

-(id) init{
    self = [super init];
    if (self) {
        self.textStore = [[TextStore alloc] init];
    }
    return self;
}


/**
 *  MARK:--------------------Text--------------------
 *  调用转到Text;
 */
-(NSDictionary*) containerWord:(NSString*)word{
    return [self.textStore getSingleWordWithText:STRTOOK(word)];
}

-(void) addWord:(NSString*)word{
    [self.textStore addWord:STRTOOK(word)];
}

-(void) addWordArr:(NSArray*)wordArr{
    [self.textStore addWordArr:wordArr];
}

@end
