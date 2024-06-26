//
//  GameScene.swift
//  PEEPOINVADERS Shared
//
//  Created by user261306 on 6/20/24.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let player: UInt32 = 0x1 << 0 // 1
        static let enemy: UInt32 = 0x1 << 1  // 2
        static let bullet: UInt32 = 0x1 << 2 // 4
        static let powerUp: UInt32 = 0x1 << 3 // 8
    }
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!

    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score:  \(score)"
        }
    }
    
    var enemySpawnTimer:Timer!
    var powerUpSpawnTimer:Timer!
    var difficultyTimer:Timer!
    var difficultyLevel : Double = 0
    
    var possibleEnemies =  ["enemy1","enemy2"]
    var possiblePowerUp = ["player"]
    
    let enemyCategory:UInt32 = 0x1 << 1
    let photonEnemyCategory:UInt32 = 0x1 << 0

    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 1

    
    override func didMove(to view: SKView) {
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: self.frame.size.width/2 , y: self.frame.size.height)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "spaceShip")
        
        player.position = CGPoint(x: self.frame.size.width/2, y: 200)
        player.zPosition = 1
        player.setScale(0.5)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.powerUp
                
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score : 0")
        scoreLabel.position = CGPoint(x: scoreLabel.frame.size.width , y: self.frame.size.height - 100)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        scoreLabel.zPosition = 2
        
        self.addChild(scoreLabel)
        
        enemySpawnTimer = Timer.scheduledTimer(timeInterval: (5 - difficultyLevel), target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true)
        powerUpSpawnTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(addPowerUp), userInfo: nil, repeats: true)
        
        difficultyTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(difficulty), userInfo: nil, repeats: true)
    }
    
    @objc func difficulty()
    {
        if difficultyLevel >= 4.9 {
            difficultyLevel += 0.1
        }
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
        
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.none
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.bullet
        
        enemy.setScale(0.05)
        
        self.addChild(enemy)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -enemy.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        enemy.run(SKAction.sequence(actionArray))
    }
    
    func fireBullet() {
        self.run( SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let bulletNode = SKSpriteNode(imageNamed: "bullet")
        bulletNode.position = player.position
        bulletNode.position.y += 5
        
        bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: bulletNode.size.width/2)
        bulletNode.physicsBody?.isDynamic = true
        
        bulletNode.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        bulletNode.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.powerUp
        bulletNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true
        
        bulletNode.setScale(0.05)
        
        self.addChild(bulletNode)
        
        let animationDuration:TimeInterval = 0.3
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 1), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        bulletNode.run(SKAction.sequence(actionArray))
        
    }
    
    @objc func addPowerUp() {
        possiblePowerUp = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possiblePowerUp) as! [String]
        
        let powerUp = SKSpriteNode(imageNamed: possiblePowerUp[0])
        
        let randomPowerUpPosition = GKRandomDistribution(lowestValue: 0, highestValue: 500)
        let position = CGFloat(randomPowerUpPosition .nextInt())
        
        powerUp.position = CGPoint(x: position, y: self.frame.size.height + powerUp.size.height)
        
        powerUp.physicsBody = SKPhysicsBody(rectangleOf: powerUp.size)
        powerUp.physicsBody?.isDynamic = true
        
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        powerUp.physicsBody?.collisionBitMask = PhysicsCategory.none
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.bullet
        
        powerUp.setScale(1)
        
        self.addChild(powerUp)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -powerUp.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        powerUp.run(SKAction.sequence(actionArray))
    }

    func didBegin(_ contact: SKPhysicsContact)
    {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if (firstBody.categoryBitMask & photonEnemyCategory) != 0 && (secondBody.categoryBitMask & enemyCategory) != 0
        {
            BulletDidCollideWithEnemy(bulletNode: firstBody.node as! SKSpriteNode, enemyNode: secondBody.node as! SKSpriteNode)
        }
        else if (firstBody.categoryBitMask & PhysicsCategory.bullet != 0) &&
                  (secondBody.categoryBitMask & PhysicsCategory.enemy != 0) {
            BulletDidCollideWithEnemy(bulletNode: firstBody.node as! SKSpriteNode, enemyNode: secondBody.node as! SKSpriteNode)
        } else if (firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
                  (secondBody.categoryBitMask & PhysicsCategory.powerUp != 0) {
            PlayerDidCollideWithPowerUp(player: firstBody.node as! SKSpriteNode, powerUp: secondBody.node as! SKSpriteNode)
        }
    }

    func BulletDidCollideWithEnemy (bulletNode:SKSpriteNode, enemyNode:SKSpriteNode){
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = enemyNode.position
        self.addChild(explosion)

        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))

        bulletNode.removeFromParent()
        enemyNode.removeFromParent()

        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }

        score += 5
    }
    
    func PlayerDidCollideWithEnemy(player: SKSpriteNode, enemy: SKSpriteNode) {
            // Handle player and enemy collision
            print("Player collided with enemy")
        }
    
    func PlayerDidCollideWithPowerUp(player: SKSpriteNode, powerUp: SKSpriteNode) {
            // Handle player and power-up collision
            print("Player collided with power-up")
        }
    
    
    func MoveLeft()
    {
        if player.position.x - player.size.width/2 > 0{
            player.position.x -= xAcceleration
        }
    }
    
    func MoveRight()
    {
        if player.position.x + player.size.width/2 < self.frame.size.width{
            player.position.x += xAcceleration
        }
    }
    
    func ShootSpecial()
    {
        
    }

    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

