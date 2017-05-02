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

class SKOrganismNode: Hashable {
    
    static var nextHashValue = 0
    var hashValue: Int
    static func ==(skON1: SKOrganismNode, skON2: SKOrganismNode) -> Bool {return skON1.hashValue == skON2.hashValue}
    
    let organismName: String
    
    let sprite: SKSpriteNode
    
    var direction = Int()
    
    var action: SKAction?

    let scene: SKScene
    
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

    
    init(organismName: String, scene: SKScene) {
        
        self.organismName = organismName
        self.hashValue = SKOrganismNode.nextHashValue
        SKOrganismNode.nextHashValue += 1
        sprite = SKSpriteNode(imageNamed: organismName)
        sprite.xScale = 0.2
        sprite.yScale = 0.2
        sprite.zPosition = 3
        
        self.scene = scene
        
    }
    
    func standby() {
        //<--- run the action in the scene, or have the class take care of it?
    }
    
    //helps manage movement stuff (sets action, switches direction)
    func faceAndMove(to destination: CGPoint, forDuration duration: Double) {
        action = SKAction.move(to: destination, duration: duration)
        
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
        
        faceAndMove(to: randomPointOnGround(), forDuration: 3)
    }
    
    func markForDeath() {
        action = nil
        sprite.clearAllActions()
    }
    
    
    func die() {
        let disintegrate = SKAction.fadeOut(withDuration: 1)
        let delete = SKAction.removeFromParent()
        
        action = SKAction.sequence([disintegrate, delete])
    }
    
    func hunt(target: SKOrganismNode) {
        
    }
    
    
}
