//
//  NVConfig.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/8/13.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#define cNodeSize (isSimulator ? 23 : 27)
#define cModuleWidth MAX(ScreenWidth * 0.25,235)
#define cModuleHeight cNVHeight - 24
#define cNVHeight MAX(ScreenHeight * 0.7,280)
#define cShowNameTime 3000

#define cLayerSpace 3.0f * cNodeSize    //层间距
#define cXSpace 0.9f * cNodeSize        //节点横间距
#define cYSpace 0.5f * cNodeSize        //同层纵间距

#define cNodeGesDistance cNodeSize      //节点滑动操作距离
