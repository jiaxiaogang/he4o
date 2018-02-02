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

@end


//MARK:===============================================================
//MARK:                     < AIIntModel >
//MARK:===============================================================
@implementation AIIntModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.from = [aDecoder decodeIntegerForKey:@"from"];
        self.to = [aDecoder decodeIntegerForKey:@"to"];
        self.algs = [aDecoder decodeObjectForKey:@"algs"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.from forKey:@"from"];
    [aCoder encodeFloat:self.to forKey:@"to"];
    [aCoder encodeObject:self.algs forKey:@"algs"];
}

@end


//MARK:===============================================================
//MARK:                     < AIFloatModel >
//MARK:===============================================================
@implementation AIFloatModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.from = [aDecoder decodeFloatForKey:@"from"];
        self.to = [aDecoder decodeFloatForKey:@"to"];
        self.algs = [aDecoder decodeObjectForKey:@"algs"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.from forKey:@"from"];
    [aCoder encodeFloat:self.to forKey:@"to"];
    [aCoder encodeObject:self.algs forKey:@"algs"];
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
//MARK:                     < AIIdentifierModel >
//MARK:===============================================================
@implementation AIIdentifierModel

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
