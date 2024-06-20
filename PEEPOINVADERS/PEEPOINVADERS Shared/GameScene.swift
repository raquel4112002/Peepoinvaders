//
//  GameScene.swift
//  PEEPOINVADERS Shared
//
//  Created by user261306 on 6/20/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!

    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score:  \(score)"
        }
        
    }
    
    var gameTimer:Timer!
    
    var possibleEnemies =  ["enemy1","enemy2"]
    
    let enemyCategory:UInt32 = 0x1 << 1
    let photonEnemyCategory:UInt32 = 0x1 << 0
    
    override func didMove(to view: SKView) {
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        
        player.position = CGPoint(x: self.frame.size.width/2, y: player.size.height/2 + 20)
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score : 0")
        scoreLabel.position = CGPoint(x: 100, y: self.frame.size.height - 60)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        //gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func addEnemy()
    {
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleEnemies) as! [String]
        
        let enemy = SKSpriteNode(imageNamed: possibleEnemies[0])
        
        let randomEnemyPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomEnemyPosition .nextInt())
        
        enemy.position = CGPoint(x: position, y: self.frame.size.height + enemy.size.height)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = photonEnemyCategory
        enemy.physicsBody?.collisionBitMask = 0
        
        self.addChild(enemy)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -enemy.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        enemy.run(SKAction.sequence(actionArray))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    func fireBullet() {
        self.run( SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let bulletNode = SKSpriteNode(imageNamed: "bullet")
        bulletNode.position = player.position
        bulletNode.position.y += 5
        
        bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: bulletNode.size.width/2)
        bulletNode.physicsBody?.isDynamic = true
        
        bulletNode.physicsBody?.categoryBitMask = photonEnemyCategory
        bulletNode.physicsBody?.contactTestBitMask = enemyCategory
        bulletNode.physicsBody?.collisionBitMask = 0
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bulletNode)
        
        let animationDuration:TimeInterval = 0.3
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        bulletNode.run(SKAction.sequence(actionArray))
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    
}
