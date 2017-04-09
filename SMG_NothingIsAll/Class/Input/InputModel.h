//
//  InputModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface InputModel : NSObject

@property (strong,nonatomic) NSString *text;
@property (strong,nonatomic) UIImage *img;
@property (strong,nonatomic) AVAudioPlayer *audio;//AudioFile;
//@property (strong,nonatomic) Do *do;//行为可以从img中解析;

@end
