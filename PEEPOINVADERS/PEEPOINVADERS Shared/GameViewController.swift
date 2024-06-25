//
//  GameViewController.swift
//  PEEPOINVADERS iOS
//
//  Created by user261306 on 6/20/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
             let scene = GameScene(size : view.bounds.size)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        let button = UIButton()
        button.setTitle("Button", for: .normal)
        button.backgroundColor = .systemRed
        view.addSubview(button)
        button.frame = CGRect(x: 100, y: 200, width: 100, height: 50)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
    }
    
    @objc func buttonPressed() {
        
    }
    

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

