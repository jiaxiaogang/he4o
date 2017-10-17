//
//  AISingleNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/10/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AISingleNode.h"
#import "AINetStore.h"

@implementation AISingleNode

-(NSMutableArray *)dataNodePointers{
    if (_dataNodePointers == nil) {
        _dataNodePointers = [[NSMutableArray alloc] init];
    }
    return _dataNodePointers;
}

-(void)run:(NSArray *)args{
    //1. 输出至dataNode
    AIDataNode *dataNode = [[AIDataNode alloc] init];
    [dataNode run:args];
    
    //2. 记录输出
    [self.dataNodePointers addObject:dataNode.pointer];
    if (ISOK(self.pointer, AIKVPointer.class)) {
        AIKVPointer *pointer = self.pointer;
        [[AINetStore sharedInstance] setObject:self folderName:pointer.folderName pointerId:pointer.pointerId];
    }else{
        NSLog(@"AISingleNodeHavERROR!!!___PointerInValid");
    }
    
}


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dataNodePointers = [aDecoder decodeObjectForKey:@"dataNodePointers"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.dataNodePointers forKey:@"dataNodePointers"];
}

@end
