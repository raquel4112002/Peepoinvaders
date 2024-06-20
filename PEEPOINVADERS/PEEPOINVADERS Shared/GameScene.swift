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
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!

    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score:  \(score)"
        }
    }
    
    var gameTimer:Timer!
    
    var possibleEnemies =  ["alien1","alien2","alien3"]
    
    let enemyCategory:UInt32 = 0x1 << 1
    let photonEnemyCategory:UInt32 = 0x1 << 0

    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0

    
    override func didMove(to view: SKView) {
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: self.frame.size.width/2 , y: self.frame.size.height)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        
        //player.position = CGPoint(x: self.frame.size.width/2, y: player.size.height/2 + 20)
        player.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)

        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score : 0")
        scoreLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
                    if let accelerometerData = data {
                        let acceleration = accelerometerData.acceleration
                        self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
                    }
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
        
        let bulletNode = SKSpriteNode(imageNamed: "torpedo")
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

    func didBegin(_ contact: SKPhysicsContact)
    {
        var firstBody: SKPhysicsBody
        var secondBody:SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if (firstBody.categoryBitMask & photonEnemyCategory) != 0 && (secondBody.categoryBitMask & enemyCategory) != 0
        {
            enemyDidCollideWithAlien(bulletNode: firstBody.node as! SKSpriteNode, enemyNode: secondBody.node as! SKSpriteNode)
        }

    }

    func enemyDidCollideWithAlien (bulletNode:SKSpriteNode, enemyNode:SKSpriteNode){
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

    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50

        if player.position.x < -20{
         player.position = CGPoint(x: self.size.width + 20,y: player.position.y)
        }
        else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)

        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

