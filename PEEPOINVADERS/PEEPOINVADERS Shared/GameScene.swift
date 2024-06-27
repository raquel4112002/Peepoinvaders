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
        static let player: UInt32 = 0x1 << 0
        static let enemy: UInt32 = 0x1 << 2
        static let bullet: UInt32 = 0x1 << 1
        static let powerUp: UInt32 = 0x1 << 3
        static let bottomBoundaryCategory: UInt32 = 0x1 << 4
        static let special: UInt32 = 0x1 << 5
    }
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!

    var livesLabel:SKLabelNode!
    var lives:Int = 5 {
        didSet{
            livesLabel.text = "Lives: \(lives)"
        }
    }
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score:  \(score)"
        }
    }
    
    var specialLabel:SKLabelNode!
    var specialValue:Int = 0 {
        didSet{
            specialLabel.text = "Special: \(specialValue)/50"
        }
    }
    
    
    var enemySpawnTimer:Timer!
    var powerUpSpawnTimer:Timer!
    var difficultyTimer:Timer!
    var difficultyLevel:Double = 0
    var peepoStarTimerStart:Timer!
    var peepoStarTimerStop:Timer!
    var peepoStartTimer:TimeInterval = 5
    
    
    var possibleEnemies =  ["enemy1","enemy2"]
    var possiblePowerUp = ["peepoStar", "peepoHeart"]

    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 1
    

    weak var gameViewController: GameViewController?

    
    override func didMove(to view: SKView) {
        
        difficultyLevel = 0
        
        // Create the bottom boundary
        let bottomBoundary = SKNode()
        bottomBoundary.position = CGPoint(x: frame.midX, y: frame.minY)
        
        // Create physics body for the boundary
        bottomBoundary.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX - 10, y: frame.minY), to: CGPoint(x: frame.maxX + 10, y: frame.minY))
        bottomBoundary.physicsBody?.categoryBitMask = PhysicsCategory.bottomBoundaryCategory
        bottomBoundary.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.powerUp
        bottomBoundary.physicsBody?.collisionBitMask = 0
        bottomBoundary.physicsBody?.isDynamic = false
        
        addChild(bottomBoundary)
        
        let topBoundary = SKNode()
        topBoundary.position = CGPoint(x: frame.midX, y: frame.minY)
        
        // Create physics body for the boundary
        topBoundary.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX - 10, y: frame.maxY), to: CGPoint(x: frame.maxX + 10, y: frame.maxY))
        topBoundary.physicsBody?.categoryBitMask = PhysicsCategory.bottomBoundaryCategory
        topBoundary.physicsBody?.contactTestBitMask = PhysicsCategory.bullet
        topBoundary.physicsBody?.collisionBitMask = 0
        topBoundary.physicsBody?.isDynamic = false
        
        addChild(topBoundary)
        
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
        scoreLabel.position = CGPoint(x: scoreLabel.frame.size.width / 2 , y: self.frame.size.height - 100)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = UIColor.white
        score = 0
        scoreLabel.zPosition = 2
        
        self.addChild(scoreLabel)
        
        livesLabel = SKLabelNode(text: "Lives : 0")
        livesLabel.position = CGPoint(x: scoreLabel.frame.size.width / 2 + 10, y: self.frame.size.height - 150)
        livesLabel.fontName = "AmericanTypewriter-Bold"
        livesLabel.fontSize = 25
        livesLabel.fontColor = UIColor.white
        lives = 500
        livesLabel.zPosition = 2
        
        self.addChild(livesLabel)
        
        specialLabel = SKLabelNode(text: "Special : 0")
        specialLabel.position = CGPoint(x: self.frame.size.width - specialLabel.frame.size.width / 2 + 20, y: 200)
        specialLabel.fontName = "AmericanTypewriter-Bold"
        specialLabel.fontSize = 13
        specialLabel.fontColor = UIColor.white
        specialValue = 0
        specialLabel.zPosition = 2
        
        self.addChild(specialLabel)
        
        enemySpawnTimer = Timer.scheduledTimer(timeInterval: 0.75 / 0.1, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true)
        powerUpSpawnTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(addPowerUp), userInfo: nil, repeats: true)
        
        difficultyTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(difficulty), userInfo: nil, repeats: true)
    }
    
    @objc func difficulty()
    {
        if difficultyLevel < 10 {
            difficultyLevel += 0.1
            let newEnemySpawnInterval = 0.75
            
            enemySpawnTimer.invalidate()
            enemySpawnTimer = Timer.scheduledTimer(timeInterval: newEnemySpawnInterval, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true)
        }
    }
    
    @objc func addEnemy()
    {
        
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleEnemies) as! [String]
        let enemy = SKSpriteNode(imageNamed: possibleEnemies[0])
        
        let randomEnemyPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomEnemyPosition .nextInt())
        
        if position < 0{
            enemy.position = CGPoint(x: position + enemy.frame.size.width/2, y: self.frame.size.height + enemy.size.height)
        }
        else if position > 414 {
            enemy.position = CGPoint(x: position - enemy.frame.size.width/2, y: self.frame.size.height + enemy.size.height)
        }
        
        enemy.position = CGPoint(x: position, y: self.frame.size.height + enemy.size.height)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.none
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.bullet | PhysicsCategory.bottomBoundaryCategory | PhysicsCategory.special
        
        enemy.setScale(0.05)
        
        self.addChild(enemy)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -enemy.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        enemy.run(SKAction.sequence(actionArray))
    }
    
    @objc func fire() {
        fireBullet()
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
        
        powerUp.name = possiblePowerUp[0] as String
        
        if powerUp.name == "peepoHeart"{
            powerUp.setScale(0.5)

        }
        if powerUp.name == "peepoStar"{
            powerUp.setScale(0.5)
        }
        
        let randomPowerUpPosition = GKRandomDistribution(lowestValue: 0, highestValue: 500)
        let position = CGFloat(randomPowerUpPosition .nextInt())
        
        powerUp.position = CGPoint(x: position, y: self.frame.size.height + powerUp.size.height)
        
        powerUp.physicsBody = SKPhysicsBody(rectangleOf: powerUp.size)
        powerUp.physicsBody?.isDynamic = true
        
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        powerUp.physicsBody?.collisionBitMask = PhysicsCategory.none
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.bullet
                        
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

        if (firstBody.categoryBitMask & PhysicsCategory.bullet) != 0 && (secondBody.categoryBitMask & PhysicsCategory.enemy) != 0 {
            BulletDidCollideWithEnemy(bullet: firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
        }
        else if (firstBody.categoryBitMask & PhysicsCategory.player) != 0 && (secondBody.categoryBitMask & PhysicsCategory.enemy) != 0 {
            PlayerDidCollideWithEnemy(player: firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
        }
        else if (firstBody.categoryBitMask & PhysicsCategory.player) != 0 && (secondBody.categoryBitMask & PhysicsCategory.powerUp) != 0 {
            PlayerDidCollideWithPowerUp(player: firstBody.node as! SKSpriteNode, powerUp: secondBody.node as! SKSpriteNode)
        }
        else if (firstBody.categoryBitMask & PhysicsCategory.bullet) != 0 && (secondBody.categoryBitMask & PhysicsCategory.powerUp) != 0 {
            BulletDidCollideWithPowerUp(bullet: firstBody.node as! SKSpriteNode, powerUp: secondBody.node as! SKSpriteNode)
        }
        else if (firstBody.categoryBitMask & PhysicsCategory.enemy) != 0 && (secondBody.categoryBitMask & PhysicsCategory.bottomBoundaryCategory) != 0{
            DestroyEnemy(enemy: firstBody.node as! SKSpriteNode )
        }
        else if (firstBody.categoryBitMask & PhysicsCategory.powerUp) != 0 && (secondBody.categoryBitMask & PhysicsCategory.bottomBoundaryCategory) != 0{
            DestroyPowerUp(powerUp: firstBody.node as! SKSpriteNode )
        }
        else if (firstBody.categoryBitMask & PhysicsCategory.bullet) != 0 && (secondBody.categoryBitMask & PhysicsCategory.bottomBoundaryCategory) != 0{
            DestroyBullet(bullet: firstBody.node as! SKSpriteNode )
        }
        else if (firstBody.categoryBitMask & PhysicsCategory.enemy) != 0 && (secondBody.categoryBitMask & PhysicsCategory.special) != 0{
            SpecialDidCollideWithEnemy(enemy:firstBody.node as! SKSpriteNode, special: secondBody.node as! SKSpriteNode)
        }
    }

    func DestroyEnemy(enemy:SKSpriteNode){
            enemy.removeFromParent()
        print("Begone ni")
    }
    func DestroyPowerUp(powerUp:SKSpriteNode){
            powerUp.removeFromParent()
        print("Begone gg")
    }
    func DestroyBullet(bullet:SKSpriteNode){
            bullet.removeFromParent()
        print("Begone er")
    }

    
    func BulletDidCollideWithEnemy (bullet:SKSpriteNode, enemy:SKSpriteNode){
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = enemy.position
        self.addChild(explosion)

        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))

        bullet.removeFromParent()
        enemy.removeFromParent()

        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }

        score += 5
        specialValue += 5
    }
    
    func PlayerDidCollideWithEnemy(player: SKSpriteNode, enemy: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = enemy.position
        self.addChild(explosion)
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        enemy.removeFromParent()
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
        
        score += 5
        specialValue += 10
        
        lives -= 1
        if lives <= 0 {
            player.removeFromParent()
            GameOver()
        }
    }
    
    func GameOver() {
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        self.view?.presentScene(gameOverScene, transition: transition)
    }
    
    
    func PlayerDidCollideWithPowerUp(player: SKSpriteNode, powerUp: SKSpriteNode) {
            powerUp.removeFromParent()
            if powerUp.name == "peepoHeart"{
                lives += 1
            }
            if powerUp.name == "peepoStar"{
                peepoStarStart()
                peepoStarStop(seconds: peepoStartTimer)
            }
        }
    
    func SpecialDidCollideWithEnemy(enemy: SKSpriteNode, special: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = enemy.position
        self.addChild(explosion)

        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))

        enemy.removeFromParent()

        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }

        score += 5
        specialValue += 5
    }
    
    func peepoStarStart () {
        peepoStarTimerStart = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    
    func peepoStarStop(seconds: TimeInterval) {
        peepoStarTimerStop = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(peepoStarStoping), userInfo: nil, repeats: false)
    }

    @objc func peepoStarStoping() {
        peepoStarTimerStart?.invalidate()
        peepoStarTimerStart = nil
    }
    
    
    
    func BulletDidCollideWithPowerUp(bullet: SKSpriteNode, powerUp: SKSpriteNode) {
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = powerUp.position
            self.addChild(explosion)
            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            bullet.removeFromParent()
            powerUp.removeFromParent()
            self.run(SKAction.wait(forDuration: 2)){
                explosion.removeFromParent()
            }
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
        if specialValue >= 50 {
            print("boom")
            self.run( SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
            
            let special = SKSpriteNode(imageNamed: "bullet")
            //let special = SKNode()
            special.size.height = 0.0001
            special.position = player.position
            
            special.physicsBody = SKPhysicsBody(rectangleOf: special.size)
            special.physicsBody?.isDynamic = true
            
            special.physicsBody?.categoryBitMask = PhysicsCategory.special
            special.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
            special.physicsBody?.collisionBitMask = 0
            special.physicsBody?.isDynamic = false
            
            self.addChild(special)
            
            let animationDuration:TimeInterval = 0.3
            
            var actionArray = [SKAction]()
            
            actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 1), duration: animationDuration))
            actionArray.append(SKAction.removeFromParent())
            
            special.run(SKAction.sequence(actionArray))
            specialValue = 0
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}

