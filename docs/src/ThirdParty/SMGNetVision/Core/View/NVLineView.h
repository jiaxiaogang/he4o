//
//  NVLineView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/17.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MARK:--------------------网络线--------------------
 *  1. 一根线,具有两个端口数据: dataA & dataB;
 */
@interface NVLineView : UIView

@property (nonnull,readonly,strong, nonatomic) NSMutableArray *data;//元素为2的数据;
-(void) light:(NSString*)lightStr;
-(void) setDataWithDataA:(id)dataA dataB:(id)dataB;
-(void) setDataWithData:(NSArray*)data;

@end
