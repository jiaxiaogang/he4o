//
//  TOMVisionDemandView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/16.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionNodeBase.h"

@interface TOMVisionDemandView : TOMVisionNodeBase

//MARK:===============================================================
//MARK:                     < override >
//MARK:===============================================================
-(void) setData:(DemandModel*)data;
-(DemandModel *)data;

@end
