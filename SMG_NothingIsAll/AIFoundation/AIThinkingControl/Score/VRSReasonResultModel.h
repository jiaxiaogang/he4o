//
//  VRSReasonResultModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/10/29.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRSReasonResultModel : NSObject

@property (strong, nonatomic) AIFoNodeBase *baseFo; //保留baseFo;
@property (strong, nonatomic) NSArray *pPorts;      //保留baseFo.pPorts;
@property (assign, nonatomic) double pScore;         //最终得分;
@property (assign, nonatomic) double sScore;         //最终得分;

@end
