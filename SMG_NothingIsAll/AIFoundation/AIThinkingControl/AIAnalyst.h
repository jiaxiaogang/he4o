//
//  AIAnalyst.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/6/10.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------核验--------------------
 *  @desc 用于核验对比cansetFo与protoFo;
 *  @version
 *      2019.xx.xx: PM算法 (参考手稿PM相关涉及);
 */
@interface AIAnalyst : NSObject

/**
 *  MARK:--------------------对比节点相同度--------------------
 */
+(AISolutionModel*) compareRCansetFo:(AIKVPointer*)cansetFo_p demand:(ReasonDemandModel*)demand;
+(AISolutionModel*) compareHCansetFo:(AIKVPointer*)cansetFo_p targetFo:(TOFoModel*)targetFoM;
+(CGFloat) compareCansetAlg:(AIKVPointer*)cansetAlg_p protoAlg:(AIKVPointer*)protoAlg_p;
+(CGFloat) compareCansetValue:(AIKVPointer*)cansetV_p protoValue:(AIKVPointer*)protoV_p;

@end
