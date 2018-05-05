//
//  AINetIndex.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/4/20.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < Index索引 (第一序列) >
//MARK:===============================================================
@class AIPointer,AIKVPointer,AIPort;
@interface AINetIndex : NSObject

-(AIPointer*) getPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource;
-(void) setIndexReference:(AIKVPointer*)indexPointer port:(AIPort*)port difValue:(int)difValue;
-(NSArray*) getIndexReference:(AIKVPointer*)indexPointer limit:(NSInteger)limit;

@end


//MARK:===============================================================
//MARK:                     < 内存DataSortModel (一组index) >
//MARK:===============================================================
@interface AINetIndexModel : NSObject <NSCoding>

@property (strong,nonatomic) NSMutableArray *pointerIds;
@property (strong,nonatomic) NSString *algsType;
@property (strong,nonatomic) NSString *dataSource;

@end
