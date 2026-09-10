# 养气功课

个人用 iOS 打卡：黄庭书院养气六招 + 读经典，一日满分 100。本地 SwiftData，无账号、无 HealthKit、无计时。

## 怎么跑

用 Xcode 打开 `YangqiGongke.xcodeproj`，scheme `YangqiGongke`，iOS 18+、仅 iPhone。模拟器可直接编；真机需选 Signing Team。

```
xcodebuild -scheme YangqiGongke -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
```

DEBUG 启动会跑 `ScoreEngine.selfCheck()`。

## 技术栈

SwiftUI · SwiftData · WidgetKit · App Group `group.com.YangqiGongke.app`。Bundle：`com.YangqiGongke.app` / `.widget`。

## 目录与约定

- `Shared/` 计分、主题、小组件快照（App 与 Widget 共用）
- `YangqiGongke/` 今日、本月、模型
- `YangqiGongkeWidget/` 仅 `TodayScoreWidget`，不要再加 Live Activity
- 作息手填：12:00–23:59 记成昨晚，过了午夜记在当日；0 点后入睡按晚于 23:30 计 0 分
- 分数只往上说，不写「还差」；输入框不要弹跳动画
- 精神面貌按总分：0–9 人还没醒 / 10–29 眼睛亮了 / 30–49 气色回来了 / 50–69 走路有风 / 70–89 神清气爽 / 90–100 满面春风
- 本月天数：已过完的月份用当月总天数，本月用今天是几号；平均分 = 总分 ÷ 天数（没记的日子按 0）
- 日历从星期日排起（日一二三四五六）；下月不可超过当前月

## 计分（满分 100）

| 项 | 满分 | 规则 |
|---|---|---|
| 作息 | 24 | 21:30 前睡 / 5:30 前起各 12；晚 10 分钟扣 1，23:30 / 7:30 为 0 |
| 打坐 | 20 | 两次里较长的算正分（90 得 15）；120 一次满，或 90+60 满（顺序不限） |
| 站桩 | 12 | 只记第一次，60 分钟满，线性 |
| 宽两秒 | 16 | 40 次满，线性 |
| 读经典 | 12 | 60 分钟满，线性 |
| 饮食 | 10 | 每餐七分饱 2 / 八分饱 1；无零食 2、饮食洁净 2 |
| 运动 | 6 | 30 分钟满，线性 |

## 当前状态

2026-09-07：功能可在模拟器编译运行。仓库尚未 `git init`。App Group 已与 Bundle 对齐为 `group.com.YangqiGongke.app`。下一步：真机装上看小组件；不要把已删的计时 / Live Activity 加回来。
