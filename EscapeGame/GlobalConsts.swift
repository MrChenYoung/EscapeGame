//
//  GlobalConsts.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import SpriteKit

//MARK: 标识场景内的物体的常量
// 小球
let BallCategory   : UInt32 = 0x1 << 0
// 地面
let GroundCategory : UInt32 = 0x1 << 1
// 砖头
let BlockCategory  : UInt32 = 0x1 << 2
// 挡板
let PaddleCategory : UInt32 = 0x1 << 3
// 墙壁
let BorderCategory : UInt32 = 0x1 << 4

//MARK: 场景内物体的zPosition值
// 砖块
let BlockzPosition: CGFloat = 10.0
// 挡板
let PaddlezPosition: CGFloat = 20.0
// 小球
let BallzPosition: CGFloat = 50.0
// 游戏内提示信息
let GameMessagezPosition: CGFloat = 80.0

//MARK: 常量字符串
// 游戏内提示文字节点标识
let GameMessageName = "gameMessage"
// 小球标识
let BallCategoryName = "ball"
// 砖块标识
let BlockCategoryName = "block"

//MARK: 常量
// 初始给小球的力
let BallImpulse: CGFloat = 3.0


