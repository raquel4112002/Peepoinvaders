//
//  GameOverScene.swift
//  PEEPOINVADERS iOS
//
//  Created by Aluno Tmp on 27/06/2024.
//

import SpriteKit

class GameOverScene: SKScene {

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "gameOverBackground")
        background.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        background.zPosition = -1
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "AmericanTypewriter-Bold"
        gameOverLabel.fontSize = 45
        gameOverLabel.fontColor = UIColor.white
        gameOverLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.addChild(gameOverLabel)
        
        let retryLabel = SKLabelNode(text: "Tap to Retry")
        retryLabel.fontName = "AmericanTypewriter-Bold"
        retryLabel.fontSize = 25
        retryLabel.fontColor = UIColor.white
        retryLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 - 100)
        self.addChild(retryLabel)
        
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        retryLabel.run(SKAction.sequence([wait, fadeIn]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: transition)
    }
}

