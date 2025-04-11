//
//  AIFeatureStep2Model.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------特征识别向具象（从局部到整体）的model--------------------
 *  @desc 说明：
 *          1、每个conPort.target(assT/protoT)对应一到多个absT。
 *          2、把每个assT / protoT 计为一组（本模型表示其中一组）。
 *
 */
@interface AIFeatureStep2Model : NSObject

+(AIFeatureStep2Model*) new:(NSInteger)conPId;

//每个assT/protoT 各有一到多个absT（表示每个assT/protoT所包含的所有absT）。
@property (strong, nonatomic) NSMutableArray *items;

//记录assT/protoT的地址。
@property (assign, nonatomic) NSInteger conPId;

-(void) updateItem:(NSInteger)absPId absAtConRect:(CGRect)absAtConRect;
-(CGRect) getItemRect:(NSInteger)absPId;

@end
