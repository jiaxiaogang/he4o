//
//  SMGUtils.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMGUtils.h"

@implementation SMGUtils

@end


/**
 *  MARK:--------------------比较--------------------
 */
@implementation SMGUtils (Compare)

+(BOOL) compareItemA:(id)itemA itemB:(id)itemB{
    if (itemA == nil && itemB == nil) {
        return true;
    }else if(itemA == nil || itemB == nil || [itemA class] != [itemB class]){
        return false;
    }else{
        if ([itemA isKindOfClass:[NSString class]]) {
            return [(NSString*)itemA isEqualToString:itemB];
        }else if ([itemA isKindOfClass:[NSNumber class]]) {
            return [itemA isEqualToNumber:itemB];
        }else{
            return [itemA isEqual:itemB];//不识别的类型
        }
    }
}

@end
