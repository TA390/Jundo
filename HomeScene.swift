//
//  GameScene.swift
//  Jundo
//
//  Created by TA on 26/04/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

class HomeScene: SKScene {
    
    var button: Button!
    
    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = false
        button = Button(scene: self)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        button.touchDown(at: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        button.touchMoved(at: pos)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        button.touchUp(at: pos)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}
