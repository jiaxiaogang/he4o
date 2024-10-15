//
//  TVPanelView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/18.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TVPanelView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "TOMVisionItemModel.h"
#import "PINDiskCache.h"
#import "TVideoWindow.h"
#import "TVSettingWindow.h"
#import "TVUtil.h"

@interface TVPanelView () <TVideoWindowDelegate>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISlider *sliderView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *speedSegment;
@property (weak, nonatomic) IBOutlet UILabel *changeLab;
@property (weak, nonatomic) IBOutlet UILabel *frameLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *loopLab;
@property (weak, nonatomic) IBOutlet UIButton *plusBtn;
@property (weak, nonatomic) IBOutlet UIButton *subBtn;
@property (strong, nonatomic) TVideoWindow *tvideoWindow;
@property (assign, nonatomic) BOOL playing;             //播放中;
@property (assign, nonatomic) CGFloat speed;            //播放速度 (其中0为直播);
@property (strong, nonatomic) NSTimer *timer;           //用于播放时计时触发器;
@property (assign, nonatomic) NSInteger changeIndex;            //当前播放中变数下标
@property (strong, nonatomic) NSMutableDictionary *changeDic;   //变化数字典 <K:后帧下标, V:变化数组>;

@end

@implementation TVPanelView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setFrame:CGRectMake(0, ScreenHeight - 40, ScreenWidth, 40)];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
    //tvideoWindow
    self.tvideoWindow = [[TVideoWindow alloc] init];
    self.tvideoWindow.delegate = self;
    
    //settingWindow
    self.settingWindow = [[TVSettingWindow alloc] init];
}

-(void) initData{
    self.models = [[NSMutableArray alloc] init];
    self.changeDic = [[NSMutableDictionary alloc] init];
    self.playing = true;
    self.speed = 0;
    self.changeIndex = 0;
}

-(void) initDisplay{
}

-(void) refreshDisplay{
    [self refreshDisplay:true];
}
-(void) refreshDisplay:(BOOL)refreshSlider{
    //1. 取model
    NSRange index = [TVUtil indexOfChangeIndex:self.changeIndex changeDic:self.changeDic];
    NSInteger mainIndex = index.location;
    NSInteger changeCount = [TVUtil countOfChangeDic:self.changeDic];
    TOMVisionItemModel *playModel = ARR_INDEX(self.models, mainIndex);
    TOMVisionItemModel *lastModel = ARR_INDEX_REVERSE(self.models, 0);
    self.changeIndex = MAX(MIN(self.changeIndex, changeCount - 1), 0);
    
    //2. 播放
    [self.delegate panelPlay:self.changeIndex];
    
    //3. 更新帧进度和循环数进度;
    self.frameLab.text = STRFORMAT(@"帧数: %ld/%ld",mainIndex + 1,self.models.count);
    self.loopLab.text = STRFORMAT(@"循环: %ld/%ld",playModel ? playModel.loopId : 0,lastModel ? lastModel.loopId : 0);
    
    //4. 更新进度条 (当前sliderValue与changeIndex不匹配时,更新进度条);
    // 2022.03.26: 分母-1,不然slider永远显示不到1的位置 (因为changeIndex最大为changeCount - 1);
    if (refreshSlider) {
        CGFloat sliderValue = self.changeIndex / ((float)changeCount - 1);
        [self.sliderView setValue:sliderValue];
    }
    
    //5. 更新时间进度;
    if (self.speed == 0) {
        self.timeLab.text = @"时长: --/--";
    }else{
        NSInteger allS = changeCount / self.speed;
        NSInteger curS = (self.changeIndex + 1) / self.speed;
        NSString *timeStr = STRFORMAT(@"时长: %ld:%ld/%ld:%ld",curS / 60,curS % 60,allS / 60,allS % 60);
        self.timeLab.text = timeStr;
    }
    
    //6. 更新变数;
    self.changeLab.text = STRFORMAT(@"变数: %ld/%ld", self.changeIndex + 1, changeCount);
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------添加新帧--------------------
 *  @version
 *      2022.05.04: 内存优化_减少无用帧 (无变化不记录 & 仅保留300帧);
 */
-(void) updateFrame{
    //1. 数据检查;
    if (!tomV2Switch || theTC.outModelManager.getAllDemand.count <= 0) {
        return;
    }
    
    //2. 新快照;
    TOMVisionItemModel *newFrame = [[TOMVisionItemModel alloc] init];
    newFrame.roots = CopyByCoding(theTC.outModelManager.getAllDemand);
    
    //2. 无变化时,不记录;
    TOMVisionItemModel *lastFrame = ARR_INDEX_REVERSE(self.models, 0);
    NSInteger changeCount = [TVUtil getChange_Item:lastFrame itemB:newFrame].count;
    if (changeCount <= 0) {
        return;
    }
    
    //2. 记录快照
    [self.models addObject:newFrame];
    
    //3. 仅保留后x00帧;
    NSInteger limit = !tomV2Switch ? 0 : 300;
    NSArray *subModels = ARR_SUB(self.models, self.models.count - limit, limit);
    [self.models removeAllObjects];
    [self.models addObjectsFromArray:ARRTOOK(subModels)];
    
    //3. 新轮循环Id;
    if (lastFrame && lastFrame.loopId < theTC.getLoopId) {
        newFrame.loopId = theTC.getLoopId;
    }
    
    //4. 计算变化数 (也不大耗能,就全重算吧);
    [self.changeDic removeAllObjects];
    [self.changeDic setDictionary:[TVUtil getChange_List:self.models]];
    
    //5. 当前直播播放中,则实时更新;
    if (self.playing && self.speed == 0) {
        self.changeIndex = [TVUtil countOfChangeDic:self.changeDic] - 1;
        [self refreshDisplay];
    }
}

-(void) getModel:(NSInteger)changeIndex complete:(void(^)(TOMVisionItemModel*,TOModelBase*))complete{
    //1. 取下标;
    NSRange index = [TVUtil indexOfChangeIndex:changeIndex changeDic:self.changeDic];
    
    //2. 取change变数组;
    NSArray *changes = [self.changeDic objectForKey:@(index.location)];
    
    //3. 将模型和变数返回;
    TOMVisionItemModel *frameModel = ARR_INDEX(self.models, index.location);
    TOModelBase *changeModel = ARR_INDEX(changes, index.length);
    complete(frameModel,changeModel);
}

//返回单帧展示时长;
-(CGFloat) getFrameShowTime{
    if (self.speed != 0) {
        return 1.0f / self.speed;
    }
    return 0;
}

//MARK:===============================================================
//MARK:                     < getset >
//MARK:===============================================================
-(void)setSpeed:(CGFloat)speed{
    //1. set
    _speed = speed;
    
    //2. 速度变化时,调整播放器播放间隔;
    if (self.timer) [self.timer invalidate];
    if (speed > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f / speed target:self selector:@selector(timeBlock) userInfo:nil repeats:true];
        });
    }
}

-(void) setPlaying:(BOOL)playing{
    _playing = playing;
    [self.playBtn setTitle:(self.playing ? @"||" : @"▶") forState:UIControlStateNormal];
}

//MARK:===============================================================
//MARK:                     < block >
//MARK:===============================================================
-(void) timeBlock {
    if (self.playing) {
        //1. 播放中时,播放下帧;
        NSInteger changeCount = [TVUtil countOfChangeDic:self.changeDic];
        if (self.changeIndex < changeCount - 1) {
            self.changeIndex ++;
            [self refreshDisplay];
        }else{
            //2. 播放完成时,停止计时器,停止播放;
            self.playing = false;
            NSLog(@"播放完成");
        }
    }
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)sliderChanged:(UISlider*)sender {
    NSInteger changeCount = [TVUtil countOfChangeDic:self.changeDic];
    self.changeIndex = (changeCount - 1) * sender.value;
    [self refreshDisplay:false];
}

- (IBAction)speedSegmentChanged:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.speed = 0.25f;
    }else if (sender.selectedSegmentIndex == 1) {
        self.speed = 0.5f;
    }else if (sender.selectedSegmentIndex == 2) {
        self.speed = 1;
    }else if (sender.selectedSegmentIndex == 3) {
        self.speed = 2.0f;
    }else if (sender.selectedSegmentIndex == 4) {
        self.speed = 3.0f;
    }else if (sender.selectedSegmentIndex == 5) {
        self.speed = 4.0f;
    }else if (sender.selectedSegmentIndex == 6) {
        self.speed = 0;
    }
    [self refreshDisplay];
}

- (IBAction)scaleSegmentChanged:(UISegmentedControl*)sender {
    CGFloat scale = 1.0f;
    if (sender.selectedSegmentIndex == 0) {
        scale = 0.25f;
    }else if (sender.selectedSegmentIndex == 1) {
        scale = 0.5f;
    }else if (sender.selectedSegmentIndex == 2) {
        scale = 1;
    }else if (sender.selectedSegmentIndex == 3) {
        scale = 2.0f;
    }else if (sender.selectedSegmentIndex == 4) {
        scale = 3.0f;
    }else if (sender.selectedSegmentIndex == 5) {
        scale = 4.0f;
    }
    [self.delegate panelScaleChanged:scale];
}

- (IBAction)playBtnClicked:(id)sender {
    self.playing = !self.playing;
}

- (IBAction)plusBtnClicked:(id)sender {
    NSInteger changeCount = [TVUtil countOfChangeDic:self.changeDic];
    if (self.changeIndex < changeCount - 1) {
        self.changeIndex++;
        [self refreshDisplay];
    }
}

- (IBAction)subBtnClicked:(id)sender {
    if (self.changeIndex > 0) {
        self.changeIndex--;
        [self refreshDisplay];
    }
}

- (IBAction)closeBtnClicked:(id)sender {
    [self.delegate panelCloseBtnClicked];
}

- (IBAction)saveBtnOnClicked:(id)sender {
    [self.tvideoWindow open];
}

- (IBAction)settingBtnClick:(id)sender {
    [self.settingWindow open];
}

//MARK:===============================================================
//MARK:                     < TVideoWindowDelegate >
//MARK:===============================================================
-(void) tvideo_ClearModels{
    [self.models removeAllObjects];
    [self.changeDic removeAllObjects];
    [self refreshDisplay];
}

/**
 *  MARK:--------------------存视频--------------------
 *  @version
 *      2022.10.12: 修复因文件夹为空存储失败的BUG;
 */
-(void) tvideo_Save:(NSString*)fileName{
    //1. 数据准备;
    NSString *cachePath = kCachePath;
    NSString *folder = STRFORMAT(@"%@/tvideo",cachePath);
    NSURL *fileURL = [NSURL fileURLWithPath:STRFORMAT(@"%@/%@.tv",folder,fileName)];
    NSData *data = OBJ2DATA(self.models);
    
    //2. 新建文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:false attributes:nil error:nil];
    BOOL success = [data writeToURL:fileURL options:NSDataWritingAtomic error:nil];
    NSLog(@"======> 存储思维录像《%@.tv》%@",fileName,success ? @"成功" : @"失败");
}

-(void) tvideo_Read:(NSString*)fileName{
    //1. 数据准备
    NSString *cachePath = kCachePath;
    NSURL *fileURL = [NSURL fileURLWithPath:STRFORMAT(@"%@/tvideo/%@",cachePath,fileName)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            //2. 异步取数据;
            NSArray *object = [NSKeyedUnarchiver unarchiveObjectWithFile:[fileURL path]];
            
            //3. 主线程同步数据和UI;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //4. 更新models
                [self.models removeAllObjects];
                [self.models addObjectsFromArray:object];
                
                //5. 计算变化数;
                [self.changeDic removeAllObjects];
                [self.changeDic setDictionary:[TVUtil getChange_List:self.models]];
                
                //6. 更新UI;
                [self refreshDisplay];
            });
        }@catch (NSException *exception) {}
    });
}

@end
