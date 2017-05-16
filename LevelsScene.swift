//
//  LevelsScene.swift
//  Jundo
//
//  Created by TA on 30/04/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

class Notification {
  
    private let scene: SKNode
    private let button: Button
    private let container: SKNode
    private let close: SKNode
    private let notice: SKNode
    private var isDisplayed: Bool
    
    var context: SKNode? { return isDisplayed ? container : nil }
    
    init(scene: SKNode, button: Button) {
        self.scene = scene
        self.button = button
        container = scene.childNode(withName: "Container")!
        close = container.childNode(withName: "Close")!
        notice = container.childNode(withName: "Notice")!
        isDisplayed = false
        container.alpha = 0.0
    }
    
    func touchUp(at: CGPoint) {
        if !isDisplayed {
            for node in scene.nodes(at: at) {
                if let name = node.name {
                    if name == button.game, button.level(button: node) == nil {
                        container.run(SKAction.sequence([SKAction.run{ Sound.pop() },
                                                         SKAction.fadeIn(withDuration: 0.2)]))
                        isDisplayed = true
                        
                        return
                    }
                }
            }
        } else if close.contains(at) || !notice.contains(at) {
            container.run(SKAction.fadeOut(withDuration: 0.2))
            isDisplayed = false
        }
    }
    
};

class LevelsScene: SKScene {
    
    private var button: Button!
    private var assets: Asset!
    private var notification: Notification!
    
    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = false
        button = Button(scene: self)
        notification = Notification(scene: self, button: button)
        assets = Asset()
        
        enumerateChildNodes(withName: button.game){
            (button, error) in
            if let level = self.button.level(button: button) {
                button.alpha = 1.0
                var gems = Setting.gems(level: level)
                button.enumerateChildNodes(withName: self.assets.gem){
                    (node, error) in
                    if gems > 0 {
                        let gem = node as! SKSpriteNode
                        gem.texture = SKTexture(imageNamed: self.assets.gem(.red))
                    }
                    gems = gems - 1
                }
                if let lock = self.childNode(withName: self.assets.lock(level: level)) {
                    lock.isHidden = true
                }
            } else {
                button.alpha = 0.5
                self.enumerateChildNodes(withName: self.assets.gem){
                    (node, error) in
                    node.alpha = button.alpha
                }
            }
        }
    }

    
    func touchDown(atPoint pos : CGPoint) {
        button.touchDown(at: pos, context: notification.context)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        button.touchMoved(at: pos, context: notification.context)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        button.touchUp(at: pos)
        notification.touchUp(at: pos)
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
