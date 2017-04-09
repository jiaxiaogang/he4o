//
//  Feel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------感觉系统--------------------
 *  1,Input信息的数字化(INPUT信息后->转化为感觉码->记忆系统)
 *  2,优先读本地,性能优化(通过对比,找到本地的相同物,有可能认错)
 *  3,图片只是简单的压缩大小,质量和模糊(图片的对比问题)(参见:笔记page9)
 *  4,视频,不是每桢单独感觉,而是按注意力来感觉;(注意力吸引参见:笔记page9)
 */
@class InputModel;
@interface Feel : NSObject

-(void) commitInputModel:(InputModel*)inputModel;

@end
