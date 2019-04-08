//
//  GameOver.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import GameplayKit

class GameOver: GKState {

    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        if previousState is Playing {
            // 游戏结束 小球停止运动
            let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
            ball.physicsBody?.isDynamic = false
        }
    }
    
    // 只对下一个状态是等待开始有效
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is WaitingForTap.Type
    }
}
