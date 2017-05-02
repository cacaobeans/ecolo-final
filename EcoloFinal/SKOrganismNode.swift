//
//  SKOrganismNode.swift
//  EcoloFinal
//
//  Created by Alex Cao on 5/1/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import SpriteKit
import GameplayKit

enum SpriteStatus {
    case Dying
    case MarkedForDeath
    case Hunting
    case Standby
    case Promenading
}

class SKOrganismNode {
    
    let factor: Factor
    let sprite: SKSpriteNode
    var direction = Int()
    var action: SKAction?
    let scene: SKScene
    var spriteStatus: SpriteStatus
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func randomInt (min: Int , max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func randomPointOnGround() -> CGPoint {
        return CGPoint(x: random(min: scene.size.width * -1 / 2 + 50, max: scene.size.width / 2 - 50), y: random(min: scene.size.height * -1 / 2 + 50, max: scene.size.height * -3 / 10))
    }

    
    init?(factor: Factor, scene: SKScene) {
        
        guard let s = SKSpriteNode(imageNamed: factor.name) else {
            return nil
        }
        self.sprite = s
        
        self.factor = factor
        
        sprite.xScale = 0.2
        sprite.yScale = 0.2
        sprite.zPosition = 3
        
        spriteStatus = .Standby
        self.scene = scene
        
    }
    
    func shortestDistanceBetweenPoints(_ p1: CGPoint, _ p2: CGPoint) -> Float {
        return hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
    }
    
    func goToRandomPoint() -> SKAction {
        let pointToGo = randomPointOnGround()
        
        var destination: CGPoint
        
        let distance = shortestDistanceBetweenPoints(sprite.position, pointToGo)
        
        if distance < 150 {
            destination = sprite.position
        } else {
            destination = pointToGo
        }
        sprite.zPosition = destination.y * -1 / 100
        
        let movement = SKAction.move(to: destination, duration: TimeInterval(random(min: 2, max: 4)))
        
        return movement
    }
    
    func standby() {
        
        action = SKAction.repeatForever(goToRandomPoint())
        
        sprite.run(action!)
    
    }
    
    

    //helps manage movement stuff (sets action, switches direction)

    func faceRightDirection(destination: CGPoint) {
        
        if sprite.position.x < destination.x {
            if direction == 1 {
            } else {
                direction = 1
                sprite.xScale = sprite.xScale * -1
            }
            
        } else if sprite.position.x > destination.x {
            if direction == -1 {
            } else {
                direction = -1
                sprite.xScale = sprite.xScale * -1
            }
        }
        
    }
    
    //How can we link the scene to the sprites within the NSOrganismSprite class?
    func promenade() {
        let randomSide = Int(arc4random_uniform(2))
        if randomSide > 1 {
            sprite.position = CGPoint(x: scene.size.width/2 + 100, y: scene.size.height/2 * -1 + 50)
            direction = -1
        } else {
            sprite.position = CGPoint(x: scene.size.width/2 * -1 - 100, y: scene.size.height/2 * -1 + 50)
            direction = 1
            sprite.xScale = sprite.xScale * -1
        }
        
        let destination = randomPointOnGround()
        faceRightDirection(destination: destination)
        action = SKAction.move(to: destination, duration: 3)
        
        sprite.run(action!)
        
    }
    
    func markForDeath() {
        action = nil
        sprite.removeAllActions()
    }
    
    
    func die() {
        
        let disintegrate = SKAction.fadeOut(withDuration: 1)
        let delete = SKAction.removeFromParent()
        
        action = SKAction.sequence([disintegrate, delete])
        
        sprite.run(action!)
        
    }
    
    func hunt(target: SKOrganismNode) {
        
        let targetPosition = target.sprite.position
        
        faceRightDirection(destination: targetPosition)
        let attack = SKAction.move(to: targetPosition, duration: 3)
        let kill = SKAction.run({target.die()})
        
        action = SKAction.sequence([attack, kill])
        
        sprite.run(action!)
        
    }
    
    
}
