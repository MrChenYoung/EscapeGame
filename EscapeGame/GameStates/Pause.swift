//
//  Pause.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import GameplayKit

class Pause: GKState {
    unowned let scene: GameScene

    // 上次运动最终速度
    private var lastVelocity: CGVector = CGVector(dx: 1.0, dy: 1.0)
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    // 游戏暂停调用
    override func didEnter(from previousState: GKState?) {
        // 记录当前小球的速度
        let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
        lastVelocity = ball.physicsBody?.velocity ?? CGVector(dx: 1.0, dy: 1.0)
    
        // 小球停止运动
        ball.physicsBody?.isDynamic = false
    }
    
    // 暂停状态结束 游戏继续
    override func willExit(to nextState: GKState) {
        let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
        // 小球收物理环境影响
        ball.physicsBody?.isDynamic = true
        
        // 恢复小球暂停以前的运动速度
        ball.physicsBody?.velocity = lastVelocity
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is Playing.Type
    }
    
}
