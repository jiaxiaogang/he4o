//
//  FeelAudioModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/10.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeelAudioModel : NSObject

@property (strong,nonatomic) id audio;
@property (assign, nonatomic) NSRange range;                    //音频的开始结束位置
@property (strong,nonatomic) NSMutableDictionary *attributes;   //附加信息

@end
