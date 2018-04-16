//
//  AIModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/5.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIModel.h"


//MARK:===============================================================
//MARK:                     < AIModel >
//MARK:===============================================================
@implementation AIModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [super init];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {}

-(NSString*) getDataType{
    if ([self isKindOfClass:[AIIdentifierModel class]]) {
        return ((AIIdentifierModel*)self).identifier;
    }else{
        return NSStringFromClass(self.class);
    }
}

@end


//MARK:===============================================================
//MARK:                     < AIIntModel >
//MARK:===============================================================
@implementation AIIntModel

+(AIIntModel*) newWithFrom:(int)from to:(int)to{
    AIIntModel *model = [[AIIntModel alloc] init];
    model.from = from;
    model.to = to;
    return model;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.from = [aDecoder decodeIntForKey:@"from"];
        self.to = [aDecoder decodeIntForKey:@"to"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInt:self.from forKey:@"from"];
    [aCoder encodeInt:self.to forKey:@"to"];
}

@end


//MARK:===============================================================
//MARK:                     < AIFloatModel >
//MARK:===============================================================
@implementation AIFloatModel

+(AIFloatModel*) newWithFrom:(CGFloat)from to:(CGFloat)to{
    AIFloatModel *model = [[AIFloatModel alloc] init];
    model.from = from;
    model.to = to;
    return model;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.from = [aDecoder decodeFloatForKey:@"from"];
        self.to = [aDecoder decodeFloatForKey:@"to"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.from forKey:@"from"];
    [aCoder encodeFloat:self.to forKey:@"to"];
}

@end


//MARK:===============================================================
//MARK:                     < AIChangeModel >
//MARK:===============================================================
@implementation AIChangeModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.from = [aDecoder decodeFloatForKey:@"from"];
        self.to = [aDecoder decodeFloatForKey:@"to"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.from forKey:@"from"];
    [aCoder encodeFloat:self.to forKey:@"to"];
}

@end


//MARK:===============================================================
//MARK:                     < AIFileModel >
//MARK:===============================================================
@implementation AIFileModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.file = [aDecoder decodeObjectForKey:@"file"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.file forKey:@"file"];
}

@end


//MARK:===============================================================
//MARK:                     < AICharModel >
//MARK:===============================================================
@implementation AICharModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSString *cStr = [aDecoder decodeObjectForKey:@"c"];
        self.c = [cStr characterAtIndex:0];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    NSString *cStr = STRFORMAT(@"%c",self.c);
    [aCoder encodeObject:cStr forKey:@"c"];
}

@end

//MARK:===============================================================
//MARK:                     < AIStringModel >
//MARK:===============================================================
@implementation AIStringModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.charPointers = [aDecoder decodeObjectForKey:@"charPointers"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.charPointers forKey:@"charPointers"];
}

-(NSMutableArray *)charPointers{
    if (_charPointers == nil) {
        _charPointers = [[NSMutableArray alloc] init];
    }
    return _charPointers;
}

@end


//MARK:===============================================================
//MARK:                     < AIArrayModel >
//MARK:===============================================================
@implementation AIArrayModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.itemPointers = [aDecoder decodeObjectForKey:@"itemPointers"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.itemPointers forKey:@"itemPointers"];
}

-(NSMutableArray *)charPointers{
    if (_itemPointers == nil) {
        _itemPointers = [[NSMutableArray alloc] init];
    }
    return _itemPointers;
}

@end


//MARK:===============================================================
//MARK:                     < AIIdentifierModel >
//MARK:===============================================================
@implementation AIIdentifierModel

+(AIIdentifierModel*) newWithIdentifier:(NSString*)identifier{
    AIIdentifierModel *model = [[AIIdentifierModel alloc] init];
    model.identifier = identifier;
    return model;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
}

@end


//MARK:===============================================================
//MARK:                     < AICMVModel >
//MARK:===============================================================
@implementation AICMVModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
}

@end
