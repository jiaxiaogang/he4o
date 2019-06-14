//
//  NodeCompareModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/14.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NodeCompareModel : NSObject

+(NodeCompareModel*) newWithBig:(id)big small:(id)small;
@property (strong, nonatomic) id bigNodeData;
@property (strong, nonatomic) id smallNodeData;

//本模型是否由a和b组成;
-(BOOL)isA:(id)a andB:(id)b;

@end
