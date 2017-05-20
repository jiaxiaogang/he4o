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
-(BOOL) containerWord:(NSString*)word{
    return [self getWord:word] != nil;
}

-(BOOL) containerWordWithWhere:(NSDictionary*)where{
    return [self getWordWithWhere:where] != nil;
}

-(NSDictionary*) getWord:(NSString*)word{
    return [self.textStore getSingleWordWithText:STRTOOK(word)];
}

-(NSDictionary*) getWordWithWhere:(NSDictionary*)where{
    return [self.textStore getSingleWordWithWhere:where];
}

-(NSDictionary*) addWord:(NSString*)word{
    return [self.textStore addWord:STRTOOK(word)];
}

/**
 *  MARK:--------------------objModel--------------------
 */
-(NSDictionary*) getObj:(NSString*)itemName{
    return [self.objStore getSingleItemWithItemName:itemName];
}

-(NSDictionary*) getObjWithWhere:(NSDictionary*)where{
    return [self.objStore getSingleItemWithWhere:where];
}

-(NSDictionary*) addObj:(NSString*)itemName{
    return [self.objStore addItem:itemName];
}

-(NSMutableArray*) addObjArr:(NSArray*)itemNameArr{
    return [self.objStore addItemNameArr:itemNameArr];
}

/**
 *  MARK:--------------------doModel--------------------
 */
-(NSDictionary*) getDo:(NSString*)itemName{
    return [self.doStore getSingleItemWithItemName:itemName];
}

-(NSDictionary*) getDoWithWhere:(NSDictionary*)where{
    return [self.doStore getSingleItemWithWhere:where];
}

-(NSDictionary*) addDo:(NSString*)itemName{
    return [self.doStore addItem:itemName];
}

-(NSMutableArray*) addDoArr:(NSArray*)itemNameArr{
    return [self.doStore addItemNameArr:itemNameArr];
}

@end
