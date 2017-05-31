//
//  InputModelBase.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "InputModelBase.h"
#import "TMCache.h"
#import "SMGHeader.h"

@interface InputModelBase ()

@property (strong,nonatomic) NSMutableArray *attributesKeys;    //属性的keys数组;

@end

@implementation InputModelBase



















/**
 *  MARK:--------------------追加属性--------------------
 *  feelValueModel:比较值
 *  key:比的是什么;(key来自tmcache存的"FeelModel_Attributes_Keys")
 */
-(void) appendFeelValueModel:(FeelValueModel*)feelValueModel withKEY:(NSString*)key{
    if (feelValueModel && [self.attributesKeys containsObject:STRTOOK(key)]) {
        NSMutableArray *valueArr = [[NSMutableArray alloc] initWithArray:[self.attributes objectForKey:STRTOOK(key)]];
        [valueArr addObject:feelValueModel];
        [self.attributes setObject:valueArr forKey:STRTOOK(key)];
    }
}


/**
 *  MARK:--------------------propertys--------------------
 */
-(NSMutableArray *)attributesKeys{
    if (_attributesKeys == nil) {
        //1,先天
        _attributesKeys = [[NSMutableArray alloc] initWithObjects:
                           AttributesKey_Position,
                           AttributesKey_Color,
                           AttributesKey_Pain,
                           AttributesKey_Hungry,
                           AttributesKey_Bright,
                           AttributesKey_Shape,
                           AttributesKey_Size,
                           AttributesKey_SizeHeight,
                           AttributesKey_SizeWidth,
                           AttributesKey_SizeLong,
                           AttributesKey_SizeThick,
                           AttributesKey_SizeDeep,
                           AttributesKey_Temperature,
                           AttributesKey_TasteSweet,
                           AttributesKey_TasteSour,
                           AttributesKey_TasteBitter,
                           AttributesKey_TastePiquant,
                           AttributesKey_TasteSalty,
                           AttributesKey_Speed, nil];
        //2,后天
        [_attributesKeys addObjectsFromArray:[[TMCache sharedCache] objectForKey:@"FeelModel_Attributes_AcquiredKeys"]];
    }
    return _attributesKeys;
}

-(void) addAttributesKey:(NSString*)key{
    if (![self.attributesKeys containsObject:STRTOOK(key)]) {
        [self.attributesKeys addObject:STRTOOK(key)];
        [[TMCache sharedCache] setObject:self.attributesKeys forKey:@"FeelModel_Attributes_AcquiredKeys"];
    }
}

-(NSMutableDictionary *)attributes{
    if (_attributes == nil) {
        _attributes = [[NSMutableDictionary alloc] init];
    }
    return _attributes;
}


@end
