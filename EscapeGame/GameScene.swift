//
//  GameScene.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/5.
//  Copyright © 2019 MrChen. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // 手指开始点击屏幕的位置
    var touchBeginLocation: CGPoint!
    
    // 背景
    lazy var backgroundNode: SKSpriteNode = {
        let bgNode = SKSpriteNode(imageNamed: "bg")
        bgNode.size = self.size
        bgNode.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        bgNode.position = CGPoint(x: 0.0, y: 0.0)
        return bgNode
    }()
    
    // 小球
    lazy var ballNode: SKSpriteNode = {
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.name = BallCategoryName
        ball.zPosition = BallzPosition
        
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        trail.targetNode = trailNode
        ball.addChild(trail)
        
        return ball
    }()
    
    // 挡板
    lazy var paddle: SKSpriteNode = {
        let paddleNode = SKSpriteNode(imageNamed: "paddle")
        paddleNode.zPosition = PaddlezPosition
        return paddleNode
    }()
    
    // 地面
    private var groundNode: SKNode = SKNode()
    
    // 游戏提示文字
    lazy var gameMessageNode: SKSpriteNode = {
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        gameMessage.zPosition = GameMessagezPosition
        gameMessage.setScale(0.0)
        return gameMessage
    }()
    
    // 游戏状态
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        WaitingForTap(scene:self),
        Playing(scene: self),
        Pause(scene: self),
        GameOver(scene: self)])
    
    // 游戏赢了还是输了
    var gameWon : Bool = false {
        didSet {
            let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
            let textureName = gameWon ? "YouWon" : "GameOver"
            let texture = SKTexture(imageNamed: textureName)
            let actionSequence = SKAction.sequence([SKAction.setTexture(texture),
                                                    SKAction.scale(to: 1.0, duration: 0.25)])
            
            gameOver.run(actionSequence)
            run(gameWon ? gameWonSound : gameOverSound)
        }
    }
    
    // 游戏音效
    let blipSound = SKAction.playSoundFileNamed("pongblip", waitForCompletion: false)
    let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
    let bambooBreakSound = SKAction.playSoundFileNamed("BambooBreak", waitForCompletion: false)
    let gameWonSound = SKAction.playSoundFileNamed("game-won", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        // 设置场景(添加Nodes)
        setScene()

        // 设置场景内物体的物理体
        setPhysicsBody()
        
        // 初始化游戏
        shuffleGame()
        
        // 设置游戏初始状态
         gameState.enter(WaitingForTap.self)
    }
    
    // 点击屏幕
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        touchBeginLocation = touch!.location(in: self)
    }
    
    // 手指在屏幕上滑动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 只有游戏处于playing状态的时候挡板才能被拖拽
        if gameState.currentState is Playing {
            // 获取手指的位置 计算移动的距离
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            
            // 计算挡板的x左边值(当前x值加上手指在屏幕上的移动差值)
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            // 调整挡板x值 防止移出屏幕外
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            // 更新挡板位置
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }
    
    // 点击事件结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 通过计算手指在屏幕上的移动距离来判断是点击屏幕还是滑动
        let touch = touches.first
        let touchEndLocation = touch!.location(in: self)
        // 求x方向和y方向的移动距离绝对值
        let offsetX = abs(touchEndLocation.x - touchBeginLocation.x)
        let offsetY = abs(touchEndLocation.y - touchBeginLocation.y)
        if offsetX < 5 && offsetY < 5 {
            // 如果手指移动范围在5以内 视作点击屏幕 更新游戏状态
            updateGameState()
        }else {
            // 否则视为滑动屏幕 移动逻辑处理在touchesMoved方法里面做
        }
    }
    
    // 监听场景内物体碰撞
    func didBegin(_ contact: SKPhysicsContact) {
        if gameState.currentState is Playing {
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            // 获取碰撞的两个物体，并区分大小
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            }else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            // 如果是小球和地板碰撞 游戏结束
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == GroundCategory {
                // 设置游戏状态为结束
                gameState.enter(GameOver.self)
                // 设置玩家输赢标识
                gameWon = false
            }
            
            // 小球和砖块碰撞
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
                // 碰撞到的砖块消失
                breakBlock(node: secondBody.node!)
                
                // 播放破碎音效
                run(bambooBreakSound)
                
                // 检测玩家是否赢了
                if isGameWon() {
                    gameState.enter(GameOver.self)
                    // 玩家赢了
                    gameWon = true
                }
            }
            
            // 小球与挡板碰撞
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory{
                // 播放音效
                run(blipPaddleSound)
            }
            
            // 小球与墙壁碰撞
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BorderCategory {
                // 播放音效
                run(blipSound)
            }
        }
        
    }
    
    // 设置场景(添加Nodes)
    func setScene() {
        // 背景图片
        addChild(backgroundNode)
        
        // 添加小球
        addChild(ballNode)
        
        // 添加挡板
        addChild(paddle)
        
        // 添加地面
        addChild(groundNode)
        
        // 添加游戏提示节点
        addChild(gameMessageNode)
    }
    
    // 添加砖块
    func addBlocks() {
        // 移除上局残留的砖块
        for vestigitalBlock in self.children where vestigitalBlock.name == BlockCategoryName {
            vestigitalBlock.removeFromParent()
        }
        
        // 添加4行砖
        let blockRowNumber: Int = 1
        // 获取每一块砖头的size
        let blockSize: CGSize = SKSpriteNode(imageNamed: "block").size
        // 计算一行最多添加几块砖
        let blockCountInRow: Int = Int(ceil(self.size.width / blockSize.width))
        // 循环把所有的砖添加上(双循环添加4行blockCountInRow列的砖块)
        for i in 0..<blockRowNumber {
            for j in 0..<blockCountInRow {
                // 计算当前砖块的position
                let blockX = blockSize.width * 0.5 + blockSize.width * CGFloat(j)
                let blockY = self.size.height - blockSize.height * 0.5 - CGFloat(i) * blockSize.height - 50.0
                let block: SKSpriteNode = SKSpriteNode(imageNamed: "block")
                block.name = BlockCategoryName
                block.position = CGPoint(x: blockX, y: blockY)
                block.zPosition = BlockzPosition
                addChild(block)
                
                // 设置砖头物理体
                let blockPhysicsBody: SKPhysicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                // 不允许旋转
                blockPhysicsBody.allowsRotation = false
                // 摩擦系数为0
                blockPhysicsBody.friction = 0.0
                // 不受重力影响
                blockPhysicsBody.affectedByGravity = false
                // 不受物理因素影响
                blockPhysicsBody.isDynamic = false
                // 标识
                blockPhysicsBody.categoryBitMask = BlockCategory
                block.physicsBody = blockPhysicsBody
            }
        }
    }
    
    // 设置场景内物体的物理体
    func setPhysicsBody() {
        // 给场景添加一个物理体，这个物理体就是一条沿着场景四周的边，限制了游戏范围，其他物理体就不会跑出这个场景
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        // 物理世界的碰撞检测代理为场景自己，这样如果这个物理世界里面有两个可以碰撞接触的物理体碰到一起了就会通知他的代理
        self.physicsBody?.categoryBitMask = BorderCategory
        self.physicsWorld.contactDelegate = self

        // 设置挡板的物理体
        let paddlePhysicsBody = SKPhysicsBody(texture: paddle.texture!, size: paddle.size)
        // 挡板摩擦系数设为0
        paddlePhysicsBody.friction = 0.0
        // 恢复系数1.0
        paddlePhysicsBody.restitution = 1.0
        // 不受物理环境因素影响
        paddlePhysicsBody.isDynamic = false
        paddle.physicsBody = paddlePhysicsBody
        paddle.physicsBody?.categoryBitMask = PaddleCategory
        
        // 设置地面物理体
        let groundPhysicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: frame.origin.x, y: frame.origin.y, width: size.width, height: 1.0))
        groundNode.physicsBody = groundPhysicsBody
        groundNode.physicsBody?.categoryBitMask = GroundCategory
        
        // 设置小球的物理体
        let ballPhysicsBody = SKPhysicsBody(texture: ballNode.texture!, size: ballNode.size)
        // 不允许小球旋转
        ballPhysicsBody.allowsRotation = false
        // 摩擦系数为0
        ballPhysicsBody.friction = 0.0
        // 小球恢复系数为1(与物体碰撞以后，小球以相同的力弹回去)
        ballPhysicsBody.restitution = 1.0
        // 小球线性阻尼(小球是否收到空气阻力,设为0表示不受空气阻力)
        ballPhysicsBody.linearDamping = 0.0
        // 小球角补偿(因为不允许旋转所以设置为0)
        ballPhysicsBody.angularDamping = 0.0
        ballNode.physicsBody = ballPhysicsBody
        ballNode.physicsBody?.categoryBitMask = BallCategory
        // 小球和地面、砖头接触会发生碰撞
        ballNode.physicsBody?.contactTestBitMask = GroundCategory | BlockCategory | PaddleCategory | BorderCategory
        // 小球不受物理环境影响
        ballNode.physicsBody?.isDynamic = false
    }
    
    // 初始化游戏
    func shuffleGame() {
        // 设置小球初始位置
        ballNode.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5 + 50)
        // 设置挡板初始位置
        paddle.position = CGPoint(x: self.size.width * 0.5, y: 20.0)
        // 添加砖块
        addBlocks()
        
        // 小球受物理环境影响
        ballNode.physicsBody?.isDynamic = true
        
        // 去掉重力加速度
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    }
    
    // 判断游戏是否赢了
    func isGameWon() -> Bool {
        // 遍历所有子节点 计算剩余砖块数量
        var numberOfBricks = 0
        self.enumerateChildNodes(withName: BlockCategoryName) { (node, stop) in
            numberOfBricks += 1
        }
        
        return numberOfBricks == 0
    }
    
    // 断开砖块
    func breakBlock(node: SKNode) {
        let particles: SKEmitterNode = SKEmitterNode(fileNamed: "BrokenPlatform")!
        particles.position = node.position
        particles.zPosition = BallzPosition + 2
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),SKAction.removeFromParent()]))
        node.removeFromParent()
    }
    
    override func update(_ currentTime: TimeInterval) {
        gameState.update(deltaTime: currentTime)
    }
    
    // 更新游戏状态
    func updateGameState() {
        switch gameState.currentState {
            case is WaitingForTap:
                // 当前是等待点击开始状态 点击屏幕开始游戏
                gameState.enter(Playing.self)
            case is Playing:
                // 当前是正在游戏状态 点击屏幕暂停
                gameState.enter(Pause.self)
                print("游戏暂停了")
            case is Pause:
                // 当前是暂停状态 点击屏幕继续游戏
                gameState.enter(Playing.self)
                print("游戏继续了")
            case is GameOver:
                // 当前是游戏结束状态 点击重新开始游戏
                // 创建新的场景替换当前场景
                let newScene = GameScene(size: self.size)
                newScene.scaleMode = .aspectFit
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                self.view?.presentScene(newScene, transition: reveal)
            default:
                break
        }
    }
}
