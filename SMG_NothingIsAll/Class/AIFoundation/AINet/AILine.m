//
//  AILine.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AILine.h"

@implementation AILine

+ (AILine*) newWithType:(AILineType)type pointers:(AIArray*)pointers
{
    AILine *value = [[self.class alloc] init];
    value.type = type;
    value.strong = [AILineStrong newWithCount:1];
    [value.pointers addObjectsFromArray:pointers.content];
    
    return value;
}

+ (AILine*) newWithType:(AILineType)type aiObjs:(NSArray*)aiObjs
{
    AILine *value = [[self.class alloc] init];
    value.type = type;
    value.strong = [AILineStrong newWithCount:1];
    if (ARRISOK(aiObjs)) {
        for (AIObject *obj in aiObjs) {
            if (ISOK(obj, AIObject.class) && POINTERISOK(obj.pointer)) {
                [value.pointers addObject:obj.pointer];
            }
        }
    }
    
    return value;
}

-(NSMutableArray *)pointers{
    if (_pointers == nil) {
        _pointers = [[NSMutableArray alloc] init];
    }
    return _pointers;
}

@end
