//
//  AIFeatureNode.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/18.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureNode.h"

@implementation AIFeatureNode

-(NSArray *)levels {
    if (!_levels) _levels = [NSArray new];
    return _levels;
}
-(NSArray *)xs {
    if (!_xs) _xs = [NSArray new];
    return _xs;
}
-(NSArray *)ys {
    if (!_ys) _ys = [NSArray new];
    return _ys;
}
-(NSArray *)rects {
    if (!_rects) _rects = [NSArray new];
    return _rects;
}

//内容的md5值，特征以content_ps和level,x,y共同生成。
-(NSString*) getHeaderNotNull {
    if (!STRISOK(self.header)) self.header = [AINetUtils getFeatureNodeHeader:self.content_ps levels:self.levels xs:self.xs ys:self.ys];
    return self.header;
}

//根据level,x,y找下标，找不到时返-1。
-(NSInteger) indexOfLevel:(NSInteger)level x:(NSInteger)x y:(NSInteger)y {
    //写该方法起因：
    //1. 在特征识别时，只是知道 根据protoIndex识别 并ref映射到target了。
    //2. 我们知道的是：target与i有映射，但不知道i与target的哪个元素有映射。
    //3. 应该根据refPort中的levelxy到target里去找对应下标，这样才能找着映射。
    for (NSInteger i = 0; i < self.count; i++) {
        if (NUMTOOK(ARR_INDEX(self.levels, i)).integerValue == level &&
            NUMTOOK(ARR_INDEX(self.xs, i)).integerValue == x &&
            NUMTOOK(ARR_INDEX(self.ys, i)).integerValue == y) {
            return i;
        }
    }
    return -1;
}

//MARK:===============================================================
//MARK:       < degree组（不进行持久化，仅用于step1识别结果的类比中） >
//MARK:===============================================================
-(NSMutableDictionary *)degreeDDic{
    if (!ISOK(_degreeDDic, NSMutableDictionary.class)) _degreeDDic = [[NSMutableDictionary alloc] initWithDictionary:_degreeDDic];
    return _degreeDDic;
}
-(void) updateDegreeDic:(NSInteger)assPId degreeDic:(NSDictionary*)degreeDic {
    [self.degreeDDic setObject:degreeDic forKey:@(assPId)];
}
-(NSDictionary*) getDegreeDic:(NSInteger)assPId {
    return [self.degreeDDic objectForKey:@(assPId)];
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.levels = [aDecoder decodeObjectForKey:@"levels"];
        self.xs = [aDecoder decodeObjectForKey:@"xs"];
        self.ys = [aDecoder decodeObjectForKey:@"ys"];
        self.rects = [aDecoder decodeObjectForKey:@"rects"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.levels forKey:@"levels"];
    [aCoder encodeObject:self.xs forKey:@"xs"];
    [aCoder encodeObject:self.ys forKey:@"ys"];
    [aCoder encodeObject:self.rects forKey:@"rects"];
}

@end
