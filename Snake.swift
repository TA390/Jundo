//
//  Snake.swift
//  Jundo
//
//  Created by TA on 02/05/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import SpriteKit


class Snake {
    
    struct Boundary {
        
        let top: CGFloat
        let bottom: CGFloat
        let right: CGFloat
        let left: CGFloat
        
        init(_ maze: MazeBase){
            let width = (maze.width-maze.step) * 0.5
            let height = (maze.height-maze.step) * 0.5
            top = height
            bottom = -height
            right = width
            left = -width
        }
        
    }
    
    var snake = [SKSpriteNode]()
    var direction: directions!
    private var boundaries: Boundary
    private var step: CGFloat!
   
    /*
        Initialise the snake's constant components.
    */
    init(_ maze: MazeBase) {
        
        step = maze.step
        boundaries = Boundary(maze)
        var imageName = "SnakeHead"
        
        for _ in 0..<3 {
            let body = SKSpriteNode(imageNamed: imageName)
            imageName = "SnakeBody"
            body.name = "body"
            snake.append(body)
        }
        
        maze.insert(snake: snake)
    }

    
    /*
        Set the alpha value for each element in snake
    */
    func alpha(_ value: CGFloat) {
        for body in snake {
            body.alpha = value
        }
    }
    
    func complete(scene: SKNode, speed: Double) {

        for body in snake {
            body.run(SKAction.fadeOut(withDuration: speed*Double(snake.count)))
        }
        
        let action = SKAction.run {
            let head = self.snake.removeFirst()
            var head_position = head.position
            for i in 0..<self.snake.count {
                let tail_position = self.snake[i].position
                self.snake[i].position = head_position
                head_position = tail_position
            }
        }
        
        var sequence = [SKAction]()
        for _ in 0..<snake.count {
            sequence.append(action)
            sequence.append(SKAction.wait(forDuration: speed))
        }
        
        scene.run(SKAction.sequence(sequence))
    }
    
    /*
        Update the snake's position.
    */
    func move(_ movement: directions){
        
        direction = movement == direction?.opposite() ? direction : movement
        
        /* Calculate the new position of the head of the snake */
        
        var head_position = snake[0].position
        
        switch direction! {
            
        case .up:
            head_position.y += step
            if head_position.y > boundaries.top {
                head_position.y = boundaries.bottom
            }
            
        case .down:
            head_position.y -= step
            if head_position.y < boundaries.bottom {
                head_position.y = boundaries.top
            }
            
        case .left:
            head_position.x -= step
            if head_position.x < boundaries.left {
                head_position.x = boundaries.right
            }
            
        case .right:
            head_position.x += step
            if head_position.x > boundaries.right {
                head_position.x = boundaries.left
            }

        }
        
        /* Move the snake */
        
        for i in 0..<snake.count {
            let tail_position = snake[i].position
            snake[i].position = head_position
            head_position = tail_position
        }
        
    }
    
}
