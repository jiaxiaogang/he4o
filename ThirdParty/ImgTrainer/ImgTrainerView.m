//
//  ImgTrainerView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/25.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "ImgTrainerView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "PINDiskCache.h"
#import "TVUtil.h"
#import "XGLabCell.h"
#import "ImgTrainerItemModel.h"

@interface ImgTrainerView () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) NSMutableArray *tvDatas;
//@property (assign, nonatomic) NSInteger tvIndex;//如果reloadData后，selectedRow高亮不会消失，则这个用不着。

@end

@implementation ImgTrainerView

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
    [self setAlpha:0.7f];
    CGFloat width = 350;//ScreenWidth * 0.667f;
    [self setFrame:CGRectMake(ScreenWidth - width - 20, 64, width, ScreenHeight - 128)];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    [self.containerView.layer setCornerRadius:8.0f];
    [self.containerView.layer setBorderWidth:1.0f];
    [self.containerView.layer setBorderColor:UIColorWithRGBHex(0x000000).CGColor];
    
    //tv
    self.tv.delegate = self;
    self.tv.dataSource = self;
    [self.tv.layer setBorderWidth:1.0f];
    [self.tv.layer setBorderColor:UIColorWithRGBHex(0x0000FF).CGColor];
}

-(void) initData{
    self.tvDatas = [NSMutableArray new];

    // Read words.txt file
    NSString *wordsPath = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"txt" inDirectory:@"assets/TinyImageNetImages"];
    NSString *wordsContent = [NSString stringWithContentsOfFile:wordsPath encoding:NSUTF8StringEncoding error:nil];
    
    // Split into lines and get first line
    NSArray *wordsLines = [wordsContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableDictionary *wordsDic = [NSMutableDictionary new];
    for (NSString *line in wordsLines) {
        
        // Find first tab position in line
        NSRange tabRange = [line rangeOfString:@"\t"];
        if (tabRange.location == NSNotFound) {
            continue;
        }

        // Extract key and value from line using tab position
        NSString *key = [line substringToIndex:tabRange.location];
        NSString *value = [line substringFromIndex:tabRange.location + 1];
        wordsDic[key] = value;
    }
    NSLog(@"读到物品名字典%ld条",wordsDic.count);
    
    // Read wnids.txt file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"wnids" ofType:@"txt" inDirectory:@"assets/TinyImageNetImages"];
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // Split into lines and create array
    NSArray *imgIds = [fileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // Collect for every one
    for (NSString *imgId in imgIds) {
        NSString *imgName = [wordsDic objectForKey:imgId];
        if (!imgId || !imgName) continue;
        [self.tvDatas addObject:[ImgTrainerItemModel new:imgId imgName:imgName]];
    }
    NSLog(@"读到物品类别数%ld条",self.tvDatas.count);
}

-(void) initDisplay{
    [self close];
}

-(void) refreshDisplay{
    //5. 重显示;
    [self.tv reloadData];
    
    ////2. tv
    //[self.tv reloadData];
    //if (self.tvIndex < self.tvDatas.count) {
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self.tv scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.tvIndex inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:true];
    //    });
    //}
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) reloadData{
    [self refreshDisplay];
}
-(void) open{
    [self setHidden:false];
}
-(void) close{
    [self setHidden:true];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)playBtnOnClick:(id)sender {
    NSIndexPath *selected = [self.tv indexPathForSelectedRow];
    ImgTrainerItemModel *model = ARR_INDEX(self.tvDatas, selected.row);
    if (model) {
        model.imgIndex++;
        NSLog(@"喂下一张图:%@ %@ %ld",model.imgId,model.imgName,model.imgIndex);
        [self refreshDisplay];
    }
}

- (IBAction)closeBtnOnClick:(id)sender {
    [self close];
}


//MARK:===============================================================
//MARK:       < UITableViewDataSource &  UITableViewDelegate>
//MARK:===============================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tvDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    ImgTrainerItemModel *model = ARR_INDEX(self.tvDatas, indexPath.row);
    [cell.textLabel setText:STRFORMAT(@"%@ %@ %ld",model.imgId,model.imgName,model.imgIndex)];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

@end
