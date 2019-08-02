//
//  NVModuleView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/12.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVModuleView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "NVNodeView.h"
#import "NodeCompareModel.h"
#import "NVViewUtil.h"
#import "NVModuleUtil.h"

@interface NVModuleView ()<NVNodeViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@end

@implementation NVModuleView

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
    [self setBackgroundColor:[UIColor clearColor]];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
}

-(void) initData{
    _nodeArr = [[NSMutableArray alloc] init];
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setDataWithModuleId:(NSString*)moduleId{
    _moduleId = moduleId;
    [self.titleLab setText:STRTOOK(self.moduleId)];
}

-(void) setDataWithNodeData:(id)nodeData{
    if (nodeData) {
        [self setDataWithNodeDatas:@[nodeData]];
    }
}

-(void) setDataWithNodeDatas:(NSArray*)nodeDatas{
    NSMutableArray *validDatas = [[NSMutableArray alloc] init];
    if (ARRISOK(nodeDatas)) {
        for (id item in nodeDatas) {
            if (![self.nodeArr containsObject:item]) {
                [self.nodeArr addObject:item];
                [validDatas addObject:item];
            }
        }
        [self refreshDisplayWithNodeDatas:validDatas];
    }
}

-(void) refreshDisplayWithNodeDatas:(NSArray*)nodeDatas{
    //1. 显示新节点
    for (id nodeData in ARRTOOK(nodeDatas)) {
        NVNodeView *nodeView = [[NVNodeView alloc] init];
        nodeView.delegate = self;
        [nodeView setDataWithNodeData:nodeData];
        [self.containerView addSubview:nodeView];
    }
    
    //2. 节点排版算法,重置计算所有节点坐标;
    [self refreshDisplay_Node];
    
    //3. 重绘关联线
    [self refreshDisplay_Line:nodeDatas];
}

-(void) clear{
    //1. 清数据
    [self.nodeArr removeAllObjects];
    
    //2. 清节点
    NSArray *nodeViews = ARRTOOK([self subViews_AllDeepWithClass:NVNodeView.class]);
    for (NVNodeView *nodeView in nodeViews) {
        [nodeView removeFromSuperview];
    }
}

//MARK:===============================================================
//MARK:                     < Node >
//MARK:===============================================================
/**
 *  MARK:--------------------节点排版算法--------------------
 *  1. 有可能,a组与b组间没抽具象关系;此时只能默认往底部排;
 */
-(void) refreshDisplay_Node{
    //1. 找出所有有关系的NodeCompareModel
    NSArray *compareModels = [self getNodeCompareModels];
    NSDictionary *indexDic = [NVModuleUtil convertIndexDicWithCompareModels:compareModels];
    
    //2. 获取分组数据;
    NSArray *sortGroups = [NVModuleUtil getSortGroups:self.nodeArr compareModels:compareModels indexDic:indexDic];
    
    //3. 根据编号计算坐标;
    NSArray *nodeViews = ARRTOOK([self subViews_AllDeepWithClass:NVNodeView.class]);
    CGFloat layerSpace = 65;//层间距
    CGFloat xSpace = 18;    //节点横间距
    CGFloat nodeSize = 20;  //节点大小
    CGFloat ySpace = 10;    //同层纵间距
    
    //4. 同层计数器 (本层节点个数)
    NSMutableDictionary *yLayerCountDic = [[NSMutableDictionary alloc] init];
    int curX = -1;
    for (NSArray *sortGroup in sortGroups) {
        for (id sortItem in sortGroup) {
            for (NVNodeView *nodeView in nodeViews) {
                if ([nodeView.data isEqual:sortItem]) {
                    //5. 取xIndex和yIndex;
                    NSData *key = [NVModuleUtil keyOfData:nodeView.data];
                    NSInteger x = ++curX;
                    NSInteger y = [NUMTOOK([indexDic objectForKey:key]) integerValue];
                    
                    //6. 同层y值偏移量 (交错3 & 偏移8)
                    NSInteger layerCount = [NUMTOOK([yLayerCountDic objectForKey:@(y)]) intValue];
                    [yLayerCountDic setObject:@(layerCount + 1) forKey:@(y)];
                    
                    //7. 节点坐标
                    float spaceX = MIN(xSpace, (self.width - nodeSize) / nodeViews.count);
                    nodeView.x = x * spaceX;
                    nodeView.y = (self.height - nodeSize) - (y * layerSpace) - (layerCount % 3) * ySpace;
                }
            }
        }
    }
}

/**
 *  MARK:--------------------收集所有nodeData的关系模型--------------------
 */
-(NSArray*)getNodeCompareModels {
    //1. 进行一一比较,并收集;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.nodeArr.count; i++) {
        for (NSInteger j = i + 1; j < self.nodeArr.count; j++) {
            id iData = ARR_INDEX(self.nodeArr, i);
            id jData = ARR_INDEX(self.nodeArr, j);
            if (iData && jData) {
                //2. n1抽象指向n2
                NSArray *iAbs = ARRTOOK([self moduleView_AbsNodeDatas:iData]);
                if ([iAbs containsObject:jData]) {
                    [result addObject:[NodeCompareModel newWithBig:jData small:iData]];
                    continue;
                }
                //3. n1具象指向n2
                NSArray *iCon = ARRTOOK([self moduleView_ConNodeDatas:iData]);
                if ([iCon containsObject:jData]) {
                    [result addObject:[NodeCompareModel newWithBig:iData small:jData]];
                }
            }
        }
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < Line >
//MARK:===============================================================
-(void) refreshDisplay_Line:(NSArray*)newNodeDatas{
    //1. 收集所有线的数据 (元素为长度为2的数组);
    NSMutableArray *lineDatas = [[NSMutableArray alloc] init];
    newNodeDatas = ARRTOOK(newNodeDatas);
    
    //2. 逐个节点进行关联判断;
    NSArray *netDatas = ARRTOOK([self moduleView_GetAllNetDatas]);
    for (id item in newNodeDatas) {
        
        //3. 取四种关联端口;
        NSArray *absDatas = ARRTOOK([self moduleView_AbsNodeDatas:item]);
        NSArray *conDatas = ARRTOOK([self moduleView_ConNodeDatas:item]);
        NSArray *contentDatas = ARRTOOK([self moduleView_ContentNodeDatas:item]);
        NSArray *refDatas = ARRTOOK([self moduleView_RefNodeDatas:item]);
        
        //4. 对网络中各节点,判定关联 (非本身 & 有关系 & 未重复)
        for (id netItem in netDatas) {
            BOOL havRelate = ([absDatas containsObject:netItem] || [conDatas containsObject:netItem] || [contentDatas containsObject:netItem] || [refDatas containsObject:netItem]);
            if (![item isEqual:netItem] && havRelate && ![NVViewUtil containsLineData:@[item,netItem] fromLineDatas:lineDatas]) {
                [lineDatas addObject:@[item,netItem]];
            }
        }
    }
    
    //5. 画线
    [self moduleView_DrawLine:lineDatas];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)clearBtnOnClick:(id)sender {
    //1. 清线
    [self.delegate moduleView_ClearLine:self.nodeArr];
    
    //2. 清数据和节点
    [self clear];
}
- (IBAction)showNameBtnOnClick:(id)sender {
    NSArray *nViews = ARRTOOK([self subViews_AllDeepWithClass:NVNodeView.class]);
    for (NVNodeView *nodeView in nViews) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_ShowName:)]) {
            NSString *showName = [self.delegate moduleView_ShowName:nodeView.data];
            [nodeView setTitle:showName showTime:10];
        }
    }
}

/**
 *  MARK:--------------------NVNodeViewDelegate--------------------
 */
-(UIView *)nodeView_GetCustomSubView:(id)nodeData{
    return [self moduleView_GetCustomSubView:nodeData];
}
-(UIColor *)nodeView_GetNodeColor:(id)nodeData{
    return [self moduleView_GetNodeColor:nodeData];
}
-(CGFloat)nodeView_GetNodeAlpha:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_GetNodeAlpha:)]) {
        return [self.delegate moduleView_GetNodeAlpha:nodeData];
    }
    return 1.0f;
}
-(NSString*) nodeView_OnClick:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_NodeOnClick:)]) {
        return [self.delegate moduleView_NodeOnClick:nodeData];
    }
    return nil;
}
-(void) nodeView_TopClick:(id)nodeData{
    NSArray *absNodeDatas = [self moduleView_AbsNodeDatas:nodeData];
    [self setDataWithNodeDatas:absNodeDatas];
    TPLog(@"absPorts:%d",absNodeDatas.count);
}
-(void) nodeView_BottomClick:(id)nodeData{
    NSArray *conNodeDatas = [self moduleView_ConNodeDatas:nodeData];
    [self setDataWithNodeDatas:conNodeDatas];
    TPLog(@"conPorts:%d",conNodeDatas.count);
}
-(void) nodeView_LeftClick:(id)nodeData{
    NSArray *contentNodeDatas = [self moduleView_ContentNodeDatas:nodeData];
    [self.delegate moduleView_SetNetDatas:contentNodeDatas];
    TPLog(@"contentPorts:%d",contentNodeDatas.count);
}
-(void) nodeView_RightClick:(id)nodeData{
    NSArray *refNodeDatas = [self moduleView_RefNodeDatas:nodeData];
    [self.delegate moduleView_SetNetDatas:refNodeDatas];
    TPLog(@"refPorts:%d",refNodeDatas.count);
}

//MARK:===============================================================
//MARK:                     < SelfDelegate >
//MARK:===============================================================
-(UIView *)moduleView_GetCustomSubView:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_GetCustomSubView:)]) {
        return [self.delegate moduleView_GetCustomSubView:nodeData];
    }
    return nil;
}
-(UIColor *)moduleView_GetNodeColor:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_GetNodeColor:)]) {
        return [self.delegate moduleView_GetNodeColor:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_AbsNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_AbsNodeDatas:)]) {
        return [self.delegate moduleView_AbsNodeDatas:nodeData];
    }
    return nil;
}
-(NSArray*)moduleView_ConNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_ConNodeDatas:)]) {
        return [self.delegate moduleView_ConNodeDatas:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_ContentNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_ContentNodeDatas:)]) {
        return [self.delegate moduleView_ContentNodeDatas:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_RefNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_RefNodeDatas:)]) {
        return [self.delegate moduleView_RefNodeDatas:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_GetAllNetDatas{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_GetAllNetDatas)]) {
        return [self.delegate moduleView_GetAllNetDatas];
    }
    return nil;
}

-(void)moduleView_DrawLine:(NSArray*)lineDatas{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_DrawLine:)]) {
        [self.delegate moduleView_DrawLine:lineDatas];
    }
}

@end
