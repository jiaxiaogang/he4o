//
//  AIKVPointer.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIKVPointer.h"

@implementation AIKVPointer

+(AIKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    AIKVPointer *pointer = [[AIKVPointer alloc] init];
    pointer.pointerId = pointerId;
    [pointer.params setObject:STRTOOK(folderName) forKey:@"folderName"];
    [pointer.params setObject:STRTOOK(algsType) forKey:@"algsType"];
    [pointer.params setObject:STRTOOK(dataSource) forKey:@"dataSource"];
    return pointer;
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(NSString*) filePath{
    NSString *pIdStr = STRFORMAT(@"%ld",self.pointerId);
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableString *fileRootPath = [[NSMutableString alloc] initWithFormat:@"%@/%@/%@/%@",cachePath,STRTOOK(self.folderName),STRTOOK(self.algsType),STRTOOK(self.dataSource)];
    for (NSInteger j = 0; j < pIdStr.length; j++) {
        [fileRootPath appendFormat:@"/%@",[pIdStr substringWithRange:NSMakeRange(j, 1)]];
    }
    return fileRootPath;
}

-(NSString*) folderName{
    return [self.params objectForKey:@"folderName"];
}

-(NSString*) algsType{
    return [self.params objectForKey:@"algsType"];
}

-(NSString*) dataSource{
    return [self.params objectForKey:@"dataSource"];
}

@end
