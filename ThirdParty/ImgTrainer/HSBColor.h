//
//  HSBColor.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/28.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSBColor : NSObject

@property (assign, nonatomic) CGFloat h;
@property (assign, nonatomic) CGFloat s;
@property (assign, nonatomic) CGFloat b;

-(void) setData:(NSString*)ds value:(CGFloat)value;
-(UIColor*) getColor;

@end
