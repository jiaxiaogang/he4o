//
//  TOMVisionNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/16.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOMVisionNodeBase : UIView

-(void) setData:(TOModelBase*)data;
-(TOModelBase *)data;
-(BOOL) isEqualByData:(DemandModel*)checkData;

@end
