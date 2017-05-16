//
//  GameScene.swift
//  Jundo
//
//  Created by TA on 26/04/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

//class BaseAction {
//    
//    let button: SKNode
//    let container: SKNode
//    var counters: [SKNode]
//    var count: Int
//    let cost: Int
//    var isPaused: Bool
//    var isPending: Bool
//    var inProgress: Bool
//    let iap: inAppPurchase
//    
//    static var controllerDeleagte: InPlayAction!
//    var scene: GameScene { return controller.scene }
//    var controller: InPlayAction { return BaseAction.controllerDeleagte }
//    var canStart: Bool { return canPurchase && (count > 0 || isPending)  }
//    var canPurchase: Bool { return cost <= Setting.gems }
//    var isEnabled: Bool {
//        get { return !container.isPaused }
//        set { container.isPaused = !newValue }
//    }
//    
//    static func != (left: BaseAction, right: BaseAction) -> Bool {
//        return left.iap != right.iap
//    }
//    
//    init(_ scene: GameScene, iap iapValue: inAppPurchase) {
//        let isEnabled = Setting.isEnabled(iap: iapValue)
//        isPaused = false
//        isPending = false
//        inProgress = false
//        iap = iapValue
//        counters = []
//        count = 0
//        cost = Setting.price(iap: iap)
//        container = scene.childNode(withName: Setting.name(iap: iapValue))!
//        button = container.childNode(withName: "Button")!
//        
//        button.alpha = alpha(enable: isEnabled)
//        container.childNode(withName: "Cost")?.alpha = button.alpha
//        container.enumerateChildNodes(withName: "Dot") {
//            node, error in
//            node.alpha = self.button.alpha
//            self.counters.append(node)
//        }
//        count = counters.count
//        initialise()
//    }
//    
//    func contains(_ point: CGPoint) -> Bool {
//        return button.contains(scene.convert(point, to: button))
//    }
//    
//    func action() {
//        // Derived class to implement action.
//        inProgress = true
//    }
//    
//    func start() {
//        if isEnabled {
//            if scene.inPlay {
//                if inProgress {
//                    stop()
//                } else if canStart {
//                    if !isPending {
//                        setup()
//                    } else {
//                        isPending = false
//                    }
//                    action()
//                }
//            } else if isPending || canPurchase {
//                setup(undo: isPending, save: false)
//                isPending = !isPending
//            }
//            
//            controller.update(caller: self)
//        }
//    }
//    
//    func stop() {
//        inProgress = false
//        update()
//    }
//    
//    func pause() {
//        isPaused = true
//        isEnabled = false
//        button.alpha = alpha(enable: false)
//    }
//    
//    func resume() {
//        isPaused = false
//        update()
//    }
//    
//    func initialise() {
//        isEnabled = Setting.isEnabled(iap: iap)
//        if isEnabled {
//            container.childNode(withName: "Lock")?.removeFromParent()
//        }
//        update()
//    }
//    
//    func update() {
//        if Setting.isEnabled(iap: iap), !isPending, !isPaused {
//            if canStart {
//                isEnabled = true
//                button.alpha = alpha(enable: isEnabled)
//                for i in 0..<count { counters[i].alpha = button.alpha }
//            } else {
//                isEnabled = false
//                button.alpha = alpha(enable: isEnabled)
//                for dot in counters { dot.alpha = button.alpha }
//            }
//        }
//    }
//    
//    private func alpha(enable: Bool) -> CGFloat {
//        return enable ? 1.0 : 0.5
//    }
//    
//    private func setup(undo: Bool = false, save: Bool = true) {
//        button.alpha = alpha(enable: undo)
//        count = count + (undo ? 1 : -1)
//        counters[(undo ? count-1 : count)].alpha = button.alpha
//        Setting.purchase(gems: (undo ? cost : -cost), save: save)
//        controller.updateGemsLabel()
//    }
//    
//}

class BaseAction {
    
    let button: SKNode
    let halo: SKNode
    let lock: SKNode
    let timer: SKNode?
    let priceLabel: SKNode
    var counters: [SKNode]
    var count: Int
    let price: Int
    let iap: inAppPurchase
    var isPaused: Bool
    var isPending: Bool
    var inProgress: Bool
    var featureEnabled: Bool
    
    static var controllerDelegate: InPlayAction!
    var controller: InPlayAction { return BaseAction.controllerDelegate }
    var actionEnabled: Bool {
        get { return !button.isPaused }
        set { button.isPaused = !newValue }
    }
    var canPurchase: Bool { return count > 0 && price <= Setting.gems }
    var canPlay: Bool { return controller.scene.inPlay && !isPaused }
    var canRun: Bool { return featureEnabled && actionEnabled }
    
    
    init(_ scene: GameScene, iap: inAppPurchase) {
        
        self.iap = iap
        isPaused = false
        isPending = false
        inProgress = false
        featureEnabled = false
        price = Setting.price(iap: iap)
        
        button = scene.childNode(withName: Setting.name(iap: iap))!
        halo = scene.childNode(withName: "\(button.name!)Halo")!
        lock = scene.childNode(withName: "\(button.name!)Lock")!
        priceLabel = button.childNode(withName: "Price")!
        timer = button.childNode(withName: "Timer")
        
        count = 0
        counters = []
        button.enumerateChildNodes(withName: "Dot") {
            node, error in
            self.counters.append(node)
            self.count = self.count + 1
        }
        
        actionEnabled = false
        unlockPurchasedActions()
    }
    
    func unlockPurchasedActions() {
        if !featureEnabled {
            featureEnabled = Setting.isEnabled(iap: iap)
            if featureEnabled {
                lock.isHidden = true
                enable()
            }
        }
        if button.isPaused {
            //
        }
    }
    
    func contains(_ point: CGPoint) -> Bool {
        return button.contains(point)
    }
    
    func run() {
        if canRun {
            if inProgress {
                stop()
            } else if canPlay {
                start()
            } else {
                queue()
            }
        }
    }
    
    func queue() {
        purchase(save: false, undo: isPending)
        isPending = !isPending
        controller.disableIfUnavailable(enableIfAvailable: !isPending)
    }
    
    func action() -> Bool {
        return true
    }
    
    func start() {
        if canPurchase || isPending {
            if action() {
                inProgress = true
                if !isPending {
                    purchase(save: true, undo: false)
                    controller.disableIfUnavailable()
                } else {
                    isPending = false
                }
            }
        }
    }
    
    func stop() {
        if inProgress {
            inProgress = false
            halo.isHidden = true
            timer?.isHidden = true
            disableIfUnavailable()
        }
    }
    
    func terminate() {
        isPending = false
        inProgress = false
        halo.isHidden = true
        timer?.isHidden = true
        disable()
    }
    
    func pause() {
        isPaused = true
        timer?.speed = 0.0
    }
    
    func resume() {
        if inProgress {
            timer?.speed = 1.0
        } else if isPending {
            start()
        }
        isPaused = false
    }
    
    func disableIfUnavailable(enableIfAvailable: Bool = false) {
        if !inProgress, !isPending {
            if !canPurchase {
                if canRun {
                    disable()
                }
            } else if featureEnabled, enableIfAvailable {
                enable()
            }
        }
    }
    
    func disable() {
        activation(on: false)
        for counter in counters { counter.alpha = button.alpha }
    }
    
    private func enable() {
        activation(on: true)
        for i in 0..<count { counters[i].alpha = button.alpha }
    }
    
     func activation(on: Bool) {
        let alpha = CGFloat(on ? 1.0 : 0.5)
        actionEnabled = on
        halo.isHidden = true
        timer?.isHidden = true
        button.alpha = alpha
        priceLabel.alpha = alpha
    }
    
    private func purchase(save: Bool, undo: Bool) {
        if undo {
            counters[count].alpha = 1.0
            Setting.purchase(gems: price, save: save)
            count = count + 1
        } else {
            count = count - 1
            counters[count].alpha = 0.5
            Setting.purchase(gems: -price, save: save)
        }
        halo.isHidden = undo
        controller.updateGemsLabel()
    }

}

class PathFinder: BaseAction {
    
    let pathNode: SKSpriteNode
    let pathFinderCanvas: SKSpriteNode
    
    override init(_ scene: GameScene, iap: inAppPurchase) {
        pathFinderCanvas = scene.canvas!.copy() as! SKSpriteNode
        pathFinderCanvas.removeAllChildren()
        pathFinderCanvas.color = .clear
        pathFinderCanvas.zPosition += 1
        pathFinderCanvas.isHidden = true
        scene.addChild(pathFinderCanvas)
        
        pathNode = SKSpriteNode()
        pathNode.color = UIColor.white.withAlphaComponent(0.5)
        pathNode.size = scene.maze.cellObjectSize(scale: 0.6)
        pathNode.isHidden = true
        
        super.init(scene, iap: iap)
    }
    
    override func action() -> Bool {
        
        controller.pause(caller: self)
        
        let maze = controller.scene.maze!
        let snake = controller.scene.snake!
        let list = maze.findPath(direction: snake.direction)
        var cell: MazeCell?
        
        if list.isEmpty {
            if isPending {
                queue()
            }
            disable()
            controller.unpause()
            
            return false
        }
        
        pathFinderCanvas.isHidden = false
        var delta = 0.0
        
        while !list.isEmpty {
            
            cell = list.pop_front()
            let path = pathNode.copy() as! SKSpriteNode
            path.position = cell!.position
            pathFinderCanvas.addChild(path)
            
            var sequence: [SKAction] = [
                SKAction.wait(forDuration: delta),
                SKAction.run{ path.isHidden = false },
                SKAction.fadeOut(withDuration: 0.6),
                SKAction.removeFromParent()
            ]
            
            cell = cell!.predecessor
            if cell == nil || cell! == maze.destination {
                sequence.append(SKAction.run{ self.stop() })
            }
            path.run(SKAction.sequence(sequence))
            delta += 0.1
        
        }
        
        while(cell != nil && cell! != maze.destination) {
        
            let path = pathNode.copy() as! SKSpriteNode
            path.position = cell!.position
            pathFinderCanvas.addChild(path)
            
            var sequence: [SKAction] = [
                SKAction.wait(forDuration: delta),
                SKAction.run{ path.isHidden = false },
                SKAction.fadeOut(withDuration: 0.6),
                SKAction.removeFromParent()
            ]
            
            cell = cell!.predecessor
            if cell == nil || cell! == maze.destination {
                sequence.append(SKAction.run{ self.stop() })
            }
            path.run(SKAction.sequence(sequence))
            delta += 0.1
        }
        
        return true
    }
    
    override func stop() {
        if inProgress {
            super.stop()
            pathFinderCanvas.removeAllChildren()
            pathFinderCanvas.isHidden = true
            controller.unpause()
        }
    }
    
};

class SnailSpeed: BaseAction {
    override func action() -> Bool {
        return true
    }
};

class Ghosting: BaseAction {
    override func action() -> Bool {
        return true
    }
};

class BreadCrumbs: BaseAction {
    override func action() -> Bool {
        return true
    }
};

class InPlayAction {
    
    var ready: Bool
    let scene: GameScene
    let maze: MazeBase
    let snake: Snake
    let gameSpeed: TimeInterval
    var gameOver: Bool
    let gemsLabelNode: SKLabelNode
    let actions: [BaseAction]
    var pathFinder: PathFinder { return actions[0] as! PathFinder }
    var snailSpeed: SnailSpeed { return actions[1] as! SnailSpeed }
    var ghosting: Ghosting { return actions[2] as! Ghosting }
    var breadCrumbs: BreadCrumbs { return actions[3] as! BreadCrumbs }
    
    init(scene gameScene: GameScene, button: Button, level: Int){
        /* TEMP CODE */
        Setting.enable(iap: .pathFinder)
        Setting.enable(iap: .ghosting)
        Setting.enable(iap: .snailSpeed)
        let g = 20
        if Setting.gems < g {
            Setting.purchase(gems: g - Setting.gems)
        }
        /* END TEMP CODE */
        
        scene = gameScene
        maze = gameScene.maze
        snake = gameScene.snake
        gameSpeed = 0.3
        gameOver = false
        ready = true
        
        gemsLabelNode = scene.childNode(withName: "GemsLabel") as! SKLabelNode
        actions = [
            PathFinder(scene, iap: .pathFinder),
            SnailSpeed(scene, iap: .snailSpeed),
            Ghosting(scene, iap: .ghosting),
            BreadCrumbs(scene, iap: .breadCrumbs)
        ]

        updateGemsLabel()
        BaseAction.controllerDelegate = self
    }
    
    func updateGemsLabel() {
        let gems = Setting.gems
        gemsLabelNode.text = "\(gems) \(gems==1 ? "gem" : "gems")"
    }
    
    func disableIfUnavailable(enableIfAvailable: Bool = false) {
        for action in actions {
            action.disableIfUnavailable(enableIfAvailable: enableIfAvailable)
        }
    }
    
    func start() {
        Setting.save(.gems)
        for action in actions {
            if action.isPending {
                action.start()
            }
        }
        let sequence = SKAction.sequence([
            SKAction.run{ self.moveSnake() },
            SKAction.wait(forDuration: gameSpeed)
        ])
        scene.canvas.run(SKAction.repeatForever(sequence))
    }
    
    func stop() {
        for action in actions {
            action.stop()
        }
    }
    
    func terminate() {
        gameOver = true
        scene.registerSwipeGestures(register: false)
        scene.canvas.removeAllActions()
        scene.canvas.isPaused = false
        for action in actions {
            action.terminate()
        }
    }
    
    func pause(caller: BaseAction) {
        ready = false
        scene.canvas.isPaused = true
        for action in actions {
            action.pause()
        }
        
    }
    
    func readyToResume() -> Bool {
        return ready
    }
    
    func unpause() {
        ready = true
    }
    
    func resume() {
        scene.canvas.isPaused = false
        for action in actions {
            action.resume()
        }
    }
    
    func run(at: CGPoint) {
        for action in actions {
            if action.contains(at) {
                action.run()
                return
            }
        }
    }
    
    func moveSnake() {
        if maze.isComplete() {
            if !gameOver {
                terminate()
                scene.levelComplete()
                snake.complete(scene: scene.canvas, speed: gameSpeed)
            }
        } else if let direction = scene.swipeDirection, maze.canMove(direction) {
            maze.move(direction)
            snake.move(direction)
        } else if !gameOver {
            terminate()
            scene.replay()
        }
    }
    
}

class GameScene: SKScene {
    
    var level: Int!
    var reload: SKNode!
    var inPlay: Bool!
    var button: Button!
    var actions: InPlayAction?
    var canvas: SKSpriteNode!
    var snake: Snake!
    var maze: MazeBase!
    var swipeDirection: directions!
    var levelCompleteOverlay: SKNode!
    private var gestureRecognisers: [UIGestureRecognizer]!
    
    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = false
        let ai = activityIndicator()
        ai.startAnimating()
        
        gestureRecognisers = []
        canvas = childNode(withName: "Canvas") as! SKSpriteNode
        levelCompleteOverlay = childNode(withName: "LevelCompleteOverlay")!
        reload = levelCompleteOverlay.childNode(withName: "Game")!
        inPlay = false
        button = Button(scene: self)
        
        do {
            maze = try MazeBase(rows: 10, cols: 10, canvas: canvas)
            snake = Snake(maze)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.actions = InPlayAction(scene: self, button: self.button, level: self.level)
                self.registerSwipeGestures(register: true)
                ai.stopAnimating()
            }

        } catch {
            print("ERROR LOADING MAZE")
        }
    }
    
    /* MARK: MarketDelegate */
    func beforeMarketClose() {

    }
    
    func replay() {
        button.action(button: reload, level: level)
    }
    
    func levelComplete() {
        
    }
    
    func activityIndicator() -> UIActivityIndicatorView {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        ai.center = view!.center
        view?.addSubview(ai)
        return ai
    }
    
    func registerSwipeGestures(register: Bool) {
        if register {
            let gestures: [UISwipeGestureRecognizerDirection] = [.up, .down, .left, .right]
            for gesture in gestures {
                let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
                swipe.direction = gesture
                view?.addGestureRecognizer(swipe)
                gestureRecognisers.append(swipe)
            }
        } else {
            while !gestureRecognisers.isEmpty {
                view?.removeGestureRecognizer(gestureRecognisers.removeLast())
            }
            swipeDirection = nil
        }
    }
    
    func swipeGesture(gesture: UIGestureRecognizer){
        
        if canvas.isPaused {
            Sound.swoosh()
            if actions?.readyToResume() == true {
                actions?.resume()
            } else {
                return
            }
        }
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.up:
                swipeDirection = .up
            case UISwipeGestureRecognizerDirection.down:
                swipeDirection = .down
            case UISwipeGestureRecognizerDirection.left:
                swipeDirection = .left
            case UISwipeGestureRecognizerDirection.right:
                swipeDirection = .right
            default:
                return
            
            }

            if !inPlay {
                inPlay = true
                actions?.start()
            }
            
        }
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        actions?.run(at: pos)
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
