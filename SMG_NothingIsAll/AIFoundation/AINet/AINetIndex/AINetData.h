//
//  AINetData.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/3.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < itemData区(第二序列) >
//MARK:===============================================================
@interface AINetData : NSObject



@end


//MARK:===============================================================
//MARK:                     < itemDataModel (一条数据) >
//MARK:===============================================================
@interface AINetDataModel : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *value;
@property (strong,nonatomic) NSMutableArray *ports;

@end
