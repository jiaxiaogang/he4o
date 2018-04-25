//
//  AINetIndex.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/4/20.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < 内存DataSort >
//MARK:===============================================================
@class AIKVPointer;
@interface AINetIndex : NSObject

-(AIKVPointer*) setObject:(NSObject*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource;
-(AIKVPointer*) objectForModel:(NSObject*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource;

@end


//MARK:===============================================================
//MARK:                     < 内存DataSortModel >
//MARK:===============================================================
@interface AINetIndexModel : NSObject <NSCoding>

@property (strong,nonatomic) NSMutableArray *pointerIds;
@property (strong,nonatomic) NSString *algsType;
@property (strong,nonatomic) NSString *dataSource;

@end
