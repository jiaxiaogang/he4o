//
//  Feel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Feel.h"
#import "InputHeader.h"
#import "SMGHeader.h"
#import "FeelHeader.h"
#import "UnderstandHeader.h"

@implementation Feel

-(void) commitInputModel:(InputModel*)inputModel{
    NSLog(@"感觉系统收到Input发来的多媒体数据");
    if (inputModel) {
        //1,图片感觉化
        FeelObjModel *imgModel = [[FeelObjModel alloc] init];
        imgModel.img = [self feelForImg:inputModel.img];
        
        //2,声音感觉化
        FeelAudioModel *audioModel = [[FeelAudioModel alloc] init];
        audioModel.audio = [self feelForAudio:inputModel.audio];
        
        //3,文本感觉化
        FeelTextModel *textModel = [[FeelTextModel alloc] init];
        textModel.text = [self feelForText:inputModel.text];
        textModel.attributes = [[NSMutableDictionary alloc] init];
        
        [[SMG sharedInstance].understand commitWithFeelModelArr:@[imgModel,audioModel,textModel]];
    }
}


//查找任务_提交收集来的原数据;
-(BOOL) commitInputModelForFindObject:(InputModel*)inputModel{
    if ([STRTOOK(inputModel.text) isEqualToString:@"正确数据"]) {
        return true;//直到找到正确的数据;或任务被打断;
    }
    return false;
}


-(NSString*) feelForText:(NSString*)text{
    //作数据检查,例如大于50字;则背不下来;只记部分;
    return STRTOOK(text);
}

-(UIImage*) feelForImg:(UIImage*)img{
    //解析出
    //先从本地找替代品;取不到合适的;再解析img;
    
    return nil;//压缩尺寸,压缩质量,压缩大小后返回;
}

-(NSObject*) feelForAudio:(NSObject*)audio{
    //先从本地找替代品;
    return nil;
}





@end
