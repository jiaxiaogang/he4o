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
@property (strong,nonatomic) ObjStore *objStore;
@property (strong,nonatomic) DoStore *doStore;

@end

@implementation MKStore

-(id) init{
    self = [super init];
    if (self) {
        self.textStore = [[TextStore alloc] init];
        self.objStore = [[ObjStore alloc] init];
        self.doStore = [[DoStore alloc] init];
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

-(NSDictionary*) containerWordWithWhere:(NSDictionary*)where{
    return [self.textStore getSingleWordWithWhere:where];
}

-(NSDictionary*) addWord:(NSString*)word{
    return [self.textStore addWord:STRTOOK(word)];
}

-(NSMutableArray*) addWordArr:(NSArray*)wordArr{
    return [self.textStore addWordArr:wordArr];
}

-(NSDictionary*) addWord:(NSString*)word withObjId:(NSString*)objId withDoId:(NSString*)doId{
    return [self.textStore addWord:word withObjId:objId withDoId:doId];
}

/**
 *  MARK:--------------------objModel--------------------
 */
-(NSDictionary*) addObj:(NSString*)itemName{
    return [self.objStore addItem:itemName];
}

-(NSMutableArray*) addObjArr:(NSArray*)itemNameArr{
    return [self.objStore addItemNameArr:itemNameArr];
}

/**
 *  MARK:--------------------doModel--------------------
 */
-(NSDictionary*) addDo:(NSString*)itemName{
    return [self.doStore addItem:itemName];
}

-(NSMutableArray*) addDoArr:(NSArray*)itemNameArr{
    return [self.doStore addItemNameArr:itemNameArr];
}

@end
