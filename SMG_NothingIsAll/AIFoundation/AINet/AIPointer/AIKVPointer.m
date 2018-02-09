//
//  AIKVPointer.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIKVPointer.h"

@implementation AIKVPointer

+(AIKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName dataType:(NSString*)dataType dataSource:(NSString*)dataSource{
    AIKVPointer *pointer = [[AIKVPointer alloc] init];
    pointer.pointerId = pointerId;
    pointer.folderName = STRTOOK(folderName);
    pointer.dataType = STRTOOK(dataType);
    pointer.dataSource = STRTOOK(dataSource);
    return pointer;
}

-(NSString*) filePath{
    NSString *pIdStr = STRFORMAT(@"%ld",self.pointerId);
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableString *fileRootPath = [[NSMutableString alloc] initWithFormat:@"%@/%@/%@/%@",cachePath,STRTOOK(self.folderName),STRTOOK(self.dataType),STRTOOK(self.dataSource)];
    for (NSInteger j = 0; j < pIdStr.length; j++) {
        [fileRootPath appendFormat:@"/%@",[pIdStr substringWithRange:NSMakeRange(j, 1)]];
    }
    return fileRootPath;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.folderName = [aDecoder decodeObjectForKey:@"folderName"];
        self.dataType = [aDecoder decodeObjectForKey:@"dataType"];
        self.dataSource = [aDecoder decodeObjectForKey:@"dataSource"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.folderName forKey:@"folderName"];
    [aCoder encodeObject:self.dataType forKey:@"dataType"];
    [aCoder encodeObject:self.dataSource forKey:@"dataSource"];
}

@end


//-(NSString*) fileName{
//    NSString *pIdStr = STRFORMAT(@"%ld",self.pointerId);
//    return [pIdStr substringFromIndex:pIdStr.length - 1];
//}
