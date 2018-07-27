//
//  AINetOutputIndex.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/24.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < 微信息Output索引 (小脑) >
//MARK:===============================================================
@class AIPointer,AIOutputKVPointer;
@interface AINetOutputIndex : NSObject

-(AIOutputKVPointer*) getDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataTo:(NSString*)dataTo ;
-(void) setIndexReference:(AIOutputKVPointer*)indexPointer target_p:(AIOutputKVPointer*)target_p difValue:(int)difValue;
-(NSArray*) getIndexReference:(AIOutputKVPointer*)indexPointer limit:(NSInteger)limit;

@end


/**
 *  MARK:--------------------内存DataSortModel (一组index)--------------------
 *  1. 排序是根据"值"大小排;
 *  2. pointerIds里存的是"值的指针"的pointerId;
 */
@interface AINetOutputIndexModel : NSObject <NSCoding>

@property (strong,nonatomic) NSMutableArray *pointerIds;
@property (strong,nonatomic) NSString *algsType;
@property (strong,nonatomic) NSString *dataTo;

@end
