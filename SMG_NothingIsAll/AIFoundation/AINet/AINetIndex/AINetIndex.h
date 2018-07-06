//
//  AINetIndex.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/4/20.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < 微信息索引 (第一序列) >
//MARK:===============================================================
@class AIPointer,AIKVPointer;
@interface AINetIndex : NSObject

-(AIPointer*) getDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource;
-(void) setIndexReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue;
-(NSArray*) getIndexReference:(AIKVPointer*)indexPointer limit:(NSInteger)limit;




//用于mv变化,等动态的值范围数据索引;
//不仅要找到"解决问题"的delta;还要根据其它数据进行联想;///参考n13p14
-(AIKVPointer*) getDeltaIndexValuePointer_Front:(NSInteger)limit;



@end


//MARK:===============================================================
//MARK:                     < 内存DataSortModel (一组index) >
//MARK:===============================================================
@interface AINetIndexModel : NSObject <NSCoding>

@property (strong,nonatomic) NSMutableArray *pointerIds;
@property (strong,nonatomic) NSString *algsType;
@property (strong,nonatomic) NSString *dataSource;

@end
