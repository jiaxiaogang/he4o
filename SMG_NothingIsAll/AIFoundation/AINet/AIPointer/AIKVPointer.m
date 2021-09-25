//
//  AIKVPointer.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIKVPointer.h"

@implementation AIKVPointer

+(AIKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem type:(AnalogyType)type{
    AIKVPointer *pointer = [[AIKVPointer alloc] init];
    pointer.pointerId = pointerId;
    pointer.isMem = isMem;
    [pointer.params setObject:STRTOOK(folderName) forKey:@"folderName"];
    [pointer.params setObject:STRTOOK(algsType) forKey:@"algsType"];
    [pointer.params setObject:STRTOOK(dataSource) forKey:@"dataSource"];
    [pointer.params setObject:STRFORMAT(@"%d",isOut) forKey:@"isOut"];
    [pointer.params setObject:STRFORMAT(@"%ld",(long)type) forKey:@"type"];
    
    if (PitIsFo(pointer) || PitIsAlg(pointer)) {
        if (type == ATGreater || type == ATLess) {
            if (![dataSource isEqualToString:@"sizeWidth"] ||
                ![dataSource isEqualToString:@"sizeHeight"] ||
                ![dataSource isEqualToString:@"colorRed"] ||
                ![dataSource isEqualToString:@"colorBlue"] ||
                ![dataSource isEqualToString:@"colorGreen"] ||
                ![dataSource isEqualToString:@"radius"] ||
                ![dataSource isEqualToString:@"direction"] ||
                ![dataSource isEqualToString:@"distance"] ||
                ![dataSource isEqualToString:@"distanceY"] ||
                ![dataSource isEqualToString:@"speed"] ||
                ![dataSource isEqualToString:@"border"] ||
                ![dataSource isEqualToString:@"posX"] ||
                ![dataSource isEqualToString:@"posY"]) {
                NSLog(@"自检2. 测生成GL的AIKVPointer时的ds是否正常赋值,因为它影响node防重;");
            }
        }else{
            
            if (![dataSource isEqualToString:@" "]) {
                NSLog(@"自检3. 测生成非GL的AIKVPointer时的ds是否为" ",因为它影响node防重;");
            }
        }
    }
    
    return pointer;
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(NSString*) filePath:(NSString*)customFolderName{
    NSString *bakFolderName = [self.params objectForKey:@"folderName"];
    [self.params setObject:STRTOOK(customFolderName) forKey:@"folderName"];
    NSString *filePath = [self filePath];
    [self.params setObject:STRTOOK(bakFolderName) forKey:@"folderName"];
    return filePath;
}

-(NSString*) filePath{
    NSString *pIdStr = STRFORMAT(@"%ld",self.pointerId);
    NSString *cachePath = kCachePath;
    NSMutableString *fileRootPath = [[NSMutableString alloc] initWithFormat:@"%@/%@/%@/%@/%@/%d",cachePath,self.folderName,self.typeStr,self.algsType,self.dataSource,self.isOut];
    for (NSInteger j = 0; j < pIdStr.length; j++) {
        [fileRootPath appendFormat:@"/%@",[pIdStr substringWithRange:NSMakeRange(j, 1)]];
    }
    return fileRootPath;
}

-(NSString*) identifier{
    return STRFORMAT(@"%@_%@_%@_%d",self.typeStr,self.algsType,self.dataSource,self.isOut);
}

//MARK:===============================================================
//MARK:                     < 单属性取值 >
//MARK:===============================================================

-(NSString*) folderName{
    return [self.params objectForKey:@"folderName"];
}

-(NSString*) algsType{
    return [self.params objectForKey:@"algsType"];
}

-(NSString*) dataSource{
    return [self.params objectForKey:@"dataSource"];
}

-(BOOL) isOut{
    return [STRTOOK([self.params objectForKey:@"isOut"]) boolValue];
}

-(NSString*) typeStr{
    return ATType2Str(self.type);
}

-(AnalogyType) type{
    return [STRTOOK([self.params objectForKey:@"type"]) intValue];
}

@end
