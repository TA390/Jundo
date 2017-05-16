//
//  Button.swift
//  Jundo
//
//  Created by TA on 29/04/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import SpriteKit

class Button {
    
    let scene: SKScene
    var selected: SKSpriteNode?
    var overlay: SKSpriteNode?
    
    let sound = "Sound"
    let mute = "Mute"
    let home = "Home"
    let levels = "Levels"
    let market = "Market"
    let game = "Game"
    let close = "Close"
    let pathFinder = "PathFinder"
    let snailSpeed = "SnailSpeed"
    let ghosting = "Ghosting"
    let breadCrumbs = "BreadCrumbs"


    init(scene: SKScene){
        self.scene = scene
        if let soundButton = scene.childNode(withName: sound) as? SKSpriteNode {
            updateSoundTexture(button: soundButton)
        }
    }
    
    func level(button: SKNode) -> Int? {
        if let level = button.userData?["level"] as? Int {
            if Setting.isEnabled(level: level) {
                return level
            }
        }
        return nil
    }
    
    func touchDown(at: CGPoint, context: SKNode? = nil) {
        if selected == nil {
            for node in (context ?? scene).nodes(at: at) {
                if !node.isPaused, let name = node.name {
                    switch name {
                    case home, levels, sound, close, market, pathFinder, snailSpeed, ghosting, breadCrumbs:
                        select(button: node)
                        return
                    case game:
                        if let _ = level(button: node) {
                            select(button: node)
                        }
                        return
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func touchMoved(at: CGPoint, context: SKNode? = nil) {
        if selected == nil {
            touchDown(at: at, context: context)
        } else if !selected!.contains(at) {
            clear(callback: nil)
            touchDown(at: at, context: context)
        }
    }
    
    func touchUp(at: CGPoint) {
        var callback: ((SKNode?) -> Void)?
        if selected?.contains(at) == true {
            callback = { button in self.action(button: button)}
        }
        deselect(callback: callback)
    }
    
    private func updateSoundTexture(button: SKSpriteNode){
        button.texture = SKTexture(imageNamed: Setting.sound ? sound : mute)
    }
    
    private func select(button: SKNode) {
        overlay = SKSpriteNode(imageNamed: "ButtonOverlay")
        selected = button as? SKSpriteNode
        overlay!.size = selected!.size
        selected!.addChild(overlay!)
        overlay!.zPosition = 10
        overlay!.setScale(0.0)
        overlay!.run(SKAction.scale(to: 1.0, duration: 0.1))
        Sound.tap()
    }
    
    private func deselect(callback: ((SKNode?) -> Void)?) {
        overlay?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.run{ self.clear(callback: callback) }
        ]))
    }
    
    private func clear(callback: ((SKNode?) -> Void)?) {
        overlay?.removeFromParent()
        callback?(selected)
        overlay = nil
        selected = nil
    }
    
    func action(button: SKNode?, level: Int? = nil) {
        if let name = button?.name {
            var sk_scene: SKScene?
                
            switch name {
            case home:
                sk_scene = HomeScene(fileNamed: "HomeScene")!
            case levels:
                sk_scene = LevelsScene(fileNamed: "LevelsScene")!
            case game:
                if let lvl = level ?? self.level(button: button!) {
                    let gameScene = GameScene(fileNamed: "GameScene")!
                    gameScene.level = lvl
                    sk_scene = gameScene
                }
            case market:
                return
            case sound:
                if let soundButton = button as? SKSpriteNode {
                    Setting.toggleSound()
                    updateSoundTexture(button: soundButton)
                }
            default:
                return
            }
            
            if sk_scene != nil {
                sk_scene!.scaleMode = .aspectFit
                scene.view?.presentScene(
                    sk_scene!,
                    transition: SKTransition.fade(with: .white, duration: 0.2)
                )
            }
        }
    }
    
};
