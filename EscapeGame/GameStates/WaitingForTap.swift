//
//  WaitingForTap.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import GameplayKit

class WaitingForTap: GKState {

    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    // 游戏状态成为等待开始调用
    override func didEnter(from previousState: GKState?) {
        // 获取游戏提示节点
        let gameMessageNode = scene.childNode(withName: GameMessageName)!
        
        // 动画显示点击开始提示
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.25)
        let textureAction = SKAction.setTexture(SKTexture(imageNamed: "TapToPlay"))
        let actionSequence = SKAction.sequence([scaleAction, textureAction])
        gameMessageNode.run(actionSequence)
    }
    
    // 游戏从等待开始状态变为正在玩状态调用
    override func willExit(to nextState: GKState) {
        // 如果进入playing状态 TapToPlay提示消失
        if nextState is Playing {
            let scale = SKAction.scale(by: 0.0, duration: 0.4)
            scene.childNode(withName: GameMessageName)!.run(scale)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is Playing.Type
    }
}
