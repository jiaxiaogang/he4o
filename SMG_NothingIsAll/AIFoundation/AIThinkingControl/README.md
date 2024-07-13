### version
* 2021.11.28: 重构为2021TC架构 (参考24164架构图);

### 待改动

1. 废弃p任务;
2. 废弃effect模块 (参考27205);
3. 架构整理: 代码结构应该也是结构化一分二分四分八如下:

    * TC
        * IN
            * 入(感知)
                * TCInput
            * 认(识别)
                * TCRecognition
            * 知(学习)
                * TCLearning
            * 需(任务)
                * TCDemand
        * OUT
            * 求(规划)
                * TCPlan
            * 决(求解)
                * TCCanset
                * TCScene
                * TCSolution
            * 策(迁移)
                * TCTransfer
            * 出(行为)
                * TCAction

4. 架构整理: 然后将各级的Util和Model都整理到自己的位置;
