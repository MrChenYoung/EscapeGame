//
//  Playing.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import GameplayKit

class Playing: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    // 游戏开始
    override func didEnter(from previousState: GKState?) {
        if previousState is WaitingForTap {
            // 给小球添加一个随机方向的力
            let ball: SKSpriteNode = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
//            ball.physicsBody!.applyImpulse(CGVector(dx: randomDirection() * BallImpulse, dy: randomDirection()))
            ball.physicsBody?.velocity = CGVector(dx: 117.0, dy: -117.0)
        }
    }
    
    // playing状态下 每一帧调用一个
    override func update(deltaTime seconds: TimeInterval) {
        // 获取小球节点
        let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
        // 设置一个最大速度
        let maxSpeed: CGFloat = 400.0
        
        // 计算速度
        let xSpeed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx)
        let ySpeed = sqrt(ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
        let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
        
        if xSpeed <= 10.0 {
            ball.physicsBody!.applyImpulse(CGVector(dx: randomDirection(), dy: 0.0))
        }
        if ySpeed <= 10.0 {
            ball.physicsBody!.applyImpulse(CGVector(dx: 0.0, dy: randomDirection()))
        }
        
        // 如果小球速度过大 给一个阻尼 降低速度
        if speed > maxSpeed {
            ball.physicsBody!.linearDamping = 0.4
        }
        else {
            ball.physicsBody!.linearDamping = 0.0
        }
    }
    
    // 游戏开始 给小球一个随机方向
    func randomDirection() -> CGFloat {
        let speedFactor: CGFloat = 1.0
        if randomFloat(from: 0.0, to: 100.0) >= 50 {
            return -speedFactor
        } else {
            return speedFactor
        }
    }
    
    // 产生一个随机数让开始的时候小球有一个随机方向
    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameOver.Type || stateClass is Pause.Type
    }

}
