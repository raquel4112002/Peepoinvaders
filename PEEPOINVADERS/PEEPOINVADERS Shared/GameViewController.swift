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

    
    var scene: GameScene!
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
                scene = GameScene(size : view.bounds.size)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        let shootBtn = UIButton()
        shootBtn.setTitle("Shoot", for: .normal)
        shootBtn.backgroundColor = .systemRed
        view.addSubview(shootBtn)
        shootBtn.frame = CGRect(x: view.bounds.size.width - 100 , y: view.bounds.size.height - 100, width: 100, height: 50)
        shootBtn.addTarget(self, action: #selector(ShootBullet), for: .touchUpInside)
        
        
        let leftBtn = UIButton()
        leftBtn.setTitle("Left", for: .normal)
        leftBtn.backgroundColor = .systemRed
        view.addSubview(leftBtn)
        leftBtn.frame = CGRect(x: 25, y: view.bounds.size.height - 100, width: 50, height: 50)
        
        leftBtn.addTarget(self, action: #selector(MoveLeftStart), for: .touchDown)
        leftBtn.addTarget(self, action: #selector(MoveLeftStop), for: .touchUpInside)
        leftBtn.addTarget(self, action: #selector(MoveLeftStop), for: .touchUpOutside)
        
        
        let rightBtn = UIButton()
        rightBtn.setTitle("Right", for: .normal)
        rightBtn.backgroundColor = .systemRed
        view.addSubview(rightBtn)
        rightBtn.frame = CGRect(x: 90, y: view.bounds.size.height - 100, width: 50, height: 50)
        rightBtn.addTarget(self, action: #selector(MoveRightStart), for: .touchDown)
        rightBtn.addTarget(self, action: #selector(MoveRightStop), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(MoveRightStop), for: .touchUpOutside)
        
        let special = UIButton()
        special.setTitle("Special", for: .normal)
        special.backgroundColor = .systemRed
        view.addSubview(special)
        special.frame = CGRect(x: view.bounds.size.width - 100 , y: view.bounds.size.height - 175, width: 100, height: 50)
        special.addTarget(self, action: #selector(ShootSpecial), for: .touchUpInside)
        
    }
    
    
    
    @objc func ShootBullet() {
        scene.fireBullet()
    }
    
    @objc func MoveLeftStart() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(performMoveLeft), userInfo: nil, repeats: true)
    }
    
    @objc func MoveLeftStop(){
        timer?.invalidate()
        timer = nil
    }
    
    @objc func performMoveLeft(){
        scene.MoveLeft()
    }
    
    @objc func MoveRightStart() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(performMoveRight), userInfo: nil, repeats: true)
    }
    
    @objc func MoveRightStop(){
        timer?.invalidate()
        timer = nil
    }
    
    @objc func performMoveRight(){
        scene.MoveRight()
    }
    
    @objc func ShootSpecial() {
        scene.ShootSpecial()
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

