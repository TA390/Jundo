//
//  TouchEffect.swift
//  Jundo
//
//  Created by TA on 27/04/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import SpriteKit

/*
    User Guide: Replace tap, paint and swipe with TouchEffect.effect in the code examples
 
    /* Tap Effect *********************************************************************/
    // Render the effect with each call to touchDown().
    touchDown(atPoint pos : CGPoint) {
        TouchEffect.tap(canvas: self, position: pos))
    }

    /* Paint Effect *******************************************************************/
    // Set the initial position of the path.
    touchDown(atPoint pos : CGPoint) {
        TouchEffect.move(to: pos)
    }
    // Add a new point and redraw the full with each call to touchMoved().
    touchMoved(toPoint pos : CGPoint) {
        TouchEffect.paint(canvas: self, point: pos)
    }
    // Clear the points in the current path.
    touchUp(atPoint pos : CGPoint) {
        TouchEffect.clear()
    }

    /* Swipe Effect *******************************************************************/
    // Set the initial position of the path.
    touchDown(atPoint pos : CGPoint) {
        TouchEffect.move(to: pos)
    }
    // Draw a new line segment with each call to touchMoved().
    touchMoved(toPoint pos : CGPoint) {
        TouchEffect.swipe(canvas: self, point: pos)
    }
    // Clear the points in the current path.
    touchUp(atPoint pos : CGPoint) {
        TouchEffect.clear()
    }

    /* Swipe Effect (With Alpha) ******************************************************/
    // Remove the current effect then set the initial position of the path.
    touchDown(atPoint pos : CGPoint) {
        TouchEffect.remove()
        TouchEffect.move(to: pos)
    }
    // Add a new point with each call to touchMoved().
    touchMoved(toPoint pos : CGPoint) {
        TouchEffect.add(swipePoint: pos)
    }
    // Redraw the effect with each call to update().
    update(_ currentTime: TimeInterval) {
        TouchEffect.swipe(canvas: self)
    }
    // Clear the points in the current path.
    touchUp(atPoint pos : CGPoint) {
        TouchEffect.clear()
    }

*/

enum touchEffectType { case tap, paint, swipe, swipeWithAlpha }

class TouchEffect {
    
    private let type: touchEffectType
    private var pathPoints: [CGPoint]
    private var shapeNode: SKShapeNode?
    private var path: UIBezierPath
    private let node: SKShapeNode
    private var redrawRequired: Bool
    private var fadeOutActionSequence: SKAction!
    private var defaultActionSequence: SKAction!
    
    init(_ _type: touchEffectType, radius: CGFloat = 20.0, colour: UIColor = .white, alpha: CGFloat = 0.5, duration: TimeInterval = 1.0) {
        
        type = _type
        path = UIBezierPath()
        redrawRequired = false
        pathPoints = []
        node = SKShapeNode(circleOfRadius: 0)
        node.isAntialiased = true
        node.zPosition = 100
        node.lineCap = .round
        node.lineJoin = .bevel
        node.lineWidth = radius*2
        node.fillColor = .clear
        node.strokeColor = colour.withAlphaComponent(alpha)
        
        defaultActionSequence = SKAction.sequence([SKAction.wait(forDuration: duration),
                                                   SKAction.removeFromParent(),
                                                   SKAction.run{self.updatePathPoints()}])
        fadeOutActionSequence = SKAction.sequence([SKAction.wait(forDuration: duration),
                                                   SKAction.fadeOut(withDuration: duration),
                                                   SKAction.removeFromParent(),
                                                   SKAction.run{self.updatePathPoints()}])
    }
    
    /* Remove all points in the path */
    func clear() {
        path.removeAllPoints()
    }
    
    /* Remove the current node from the scene, along with all points for the path */
    func remove() {
        clear()
        pathPoints.removeAll()
        shapeNode?.removeFromParent()
    }
    
    /* Move the path to point @to. */
    func move(to: CGPoint) {
        path.move(to: to)
    }
    
    /* Append @swipePoint to the array pathPoints. */
    func add(swipePoint: CGPoint) {
        pathPoints.append(swipePoint)
        redrawRequired = true
    }
    
    /* Public interface for the effect. */
    func effect(canvas: SKNode, point: CGPoint?) {
        switch(type){
        case .tap:
            tap(canvas: canvas, position: point!)
        case .paint:
            paint(canvas: canvas, point: point!)
        case .swipe:
            swipe(canvas: canvas, point: point!)
        case .swipeWithAlpha:
            swipe(canvas: canvas)
        }
    }
    
    /* Render the tap effect at position @pos and add it to @canvas */
    private func tap(canvas: SKNode, position: CGPoint) {
        shapeNode = node.copy() as? SKShapeNode
        shapeNode!.run(fadeOutActionSequence)
        shapeNode!.position = position
        canvas.addChild(shapeNode!)
    }
    
    /* Extend the current path to @point then draw the new path in @canvas. */
    private func paint(canvas: SKNode, point: CGPoint) {
        path.addQuadCurve(to: point, controlPoint: point)
        shapeNode?.removeFromParent()
        shapeNode = clone(path.cgPath, action: fadeOutActionSequence)
        canvas.addChild(shapeNode!)
    }
    
    /* Draw a line segment from the end of the path to @point */
    private func swipe(canvas: SKNode, point: CGPoint) {
        path.addQuadCurve(to: point, controlPoint: path.currentPoint)
        shapeNode = clone(path.cgPath, action: fadeOutActionSequence)
        path.removeAllPoints()
        path.move(to: point)
        canvas.addChild(shapeNode!)
    }
    
    /* Redraw the path from the points in pathPoints. */
    private func swipe(canvas: SKNode) {
        if redrawRequired {
            redrawRequired = false
            path.removeAllPoints()
            if let startPoint = pathPoints.first {
                path.move(to: startPoint)
                for point in pathPoints {
                    path.addQuadCurve(to: point, controlPoint: point)
                }
                /* Hide the node instead of removing it so that its action is called. */
                shapeNode?.isHidden = true
                shapeNode = clone(path.cgPath, action: defaultActionSequence)
                canvas.addChild(shapeNode!)
            } else {
                shapeNode?.removeFromParent()
            }
        }
    }
    
    /* Remove the first point in pathPoints */
    private func updatePathPoints() {
        if !pathPoints.isEmpty {
            redrawRequired = true
            pathPoints.removeFirst()
        }
    }
    
    /* Return a copy of the class variable 'node' drawn along @path with @action */
    private func clone(_ path: CGPath, action: SKAction) -> SKShapeNode {
        shapeNode = node.copy() as? SKShapeNode
        shapeNode!.run(action)
        shapeNode!.path = path
        return shapeNode!
    }
    
}
