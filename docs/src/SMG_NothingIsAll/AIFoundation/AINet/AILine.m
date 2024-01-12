////
////  AILine.m
////  SMG_NothingIsAll
////
////  Created by 贾  on 2017/6/29.
////  Copyright © 2017年 XiaoGang. All rights reserved.
////
//
//#import "AILine.h"
//#import "AIPort.h"
//#import "AIPointer.h"
//#import "AILineStrong.h"
//#import "AIArray.h"
//
//@implementation AILine
//
//+ (AILine*) newWithType:(AILineType)type pointers:(AIArray*)pointers
//{
//    AILine *value = [[self.class alloc] init];
//    value.type = type;
//    value.strong = [AILineStrong newWithCount:1];
//    [value.port.pointers addObjectsFromArray:pointers.content];
//    
//    return value;
//}
//
//+ (AILine*) newWithType:(AILineType)type aiObjs:(NSArray*)aiObjs
//{
//    AILine *value = [[self.class alloc] init];
//    value.type = type;
//    value.strong = [AILineStrong newWithCount:1];
//    if (ARRISOK(aiObjs)) {
//        for (AIObject *obj in aiObjs) {
//            if (ISOK(obj, AIObject.class) && POINTERISOK(obj.pointer)) {
//                [value.port.pointers addObject:obj.pointer];
//            }
//        }
//    }
//    
//    return value;
//}
//
//
//-(AIPort *)port {
//    if (_port == nil) {
//        _port = [[AIPort alloc] init];
//    }
//    return _port;
//}
//
//
///**
// *  MARK:--------------------取另一头--------------------
// */
//-(NSArray*) otherPointers:(AIPointer*)pointer{
//    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:self.port.pointers];
//    for (AIPointer *item in mArr) {
//        if (POINTERISOK(item) && [item isEqual:pointer]) {
//            [mArr removeObject:item];
//            return mArr;
//        }
//    }
//    return nil;
//}
//
//
//@end

