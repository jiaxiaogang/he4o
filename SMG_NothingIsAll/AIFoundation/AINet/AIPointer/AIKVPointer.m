//
//  AIKVPointer.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIKVPointer.h"

@implementation AIKVPointer

+(AIKVPointer*) newWithPointerId:(NSInteger)pointerId folderName:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut type:(AnalogyType)type{
    AIKVPointer *pointer = [[AIKVPointer alloc] init];
    pointer.pointerId = pointerId;
    [pointer.params setObject:STRTOOK(folderName) forKey:@"folderName"];
    [pointer.params setObject:STRTOOK(algsType) forKey:@"algsType"];
    [pointer.params setObject:STRTOOK(dataSource) forKey:@"dataSource"];
    [pointer.params setObject:STRFORMAT(@"%d",isOut) forKey:@"isOut"];
    [pointer.params setObject:STRFORMAT(@"%ld",(long)type) forKey:@"type"];
    
    //自检;
    [AITest test2:pointer type:type at:algsType ds:dataSource];
    [AITest test3:pointer type:type ds:dataSource];
    [AITest test4:pointer at:algsType isOut:isOut];
    [AITest test5:pointer type:type at:algsType];
    
    return pointer;
}

//MARK:===============================================================
//MARK:                     < override >
//MARK:===============================================================
-(BOOL) isEqual:(AIKVPointer*)object{//重写指针对比地址方法;
    //1. 现在mv有两种节点类型,可能是M也可能是A,所以此处兼容一下,只要algsType和urgent一致,则返回true;
    //注: 等以后M彻底废弃改用A了,此处可去掉
    if (PitIsMv(self) && !PitIsMv(object)) {
        return [AINetUtils equal4Mv:self alg_p:object];
    }
    if (!PitIsMv(self) && PitIsMv(object)) {
        return [AINetUtils equal4Mv:object alg_p:self];
    }
    
    //2. 正常的pointer判等;
    return [super isEqual:object];
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
