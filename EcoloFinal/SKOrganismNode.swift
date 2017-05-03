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
    case Introducing
    case Killed //Added new case to distinguish handling for death between .MarkedForDeath SKOrganismNode that gets killed by predator vs. one that is told to die before it can get killed by predator
}

class SKOrganismNode: SKSpriteNode {
    
    let factor: Factor
    //let sprite: SKSpriteNode
    var direction = Int()
    //var action: SKAction?
    //let scene: SKScene
    var spriteStatus: SpriteStatus
    var target: SKOrganismNode?
    
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
        return CGPoint(x: random(min: scene!.size.width * -1 / 2 + 50, max: scene!.size.width / 2 - 50), y: random(min: scene!.size.height * -1 / 2 + 50, max: scene!.size.height * -3 / 10))
    }
    
    
    required init(factor: Factor) {
        self.factor = factor
        
        //self.xScale = 0.2
        //self.yScale = 0.2
        //self.zPosition = 3
        
        self.spriteStatus = .Standby
        let texture = SKTexture(imageNamed: factor.name)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shortestDistanceBetweenPoints(_ p1: CGPoint, _ p2: CGPoint) -> Float {
        return hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
    }
    
    func goToRandomPoint() -> SKAction {
        
        var destination: CGPoint
        
        let pointToGo = randomPointOnGround()
            
        let distance = shortestDistanceBetweenPoints(self.position, pointToGo)
        
        if distance < 150 {
            destination = self.position
        } else {
            destination = pointToGo
        }
        self.zPosition = destination.y * -1 / 100
        
        return SKAction.move(to: destination, duration: TimeInterval(random(min: 2, max: 4)))
    }
    
    func standby() {
        
        spriteStatus = .Standby
        
        self.removeAllActions()
        
        self.run(SKAction.repeatForever(goToRandomPoint()))
    }
    
    
    //When sprite animations begin becoming a thing, we can use SKAction.group to move and animate sprite at the same time (SKAction.group, SKAction.sequence, SKAction.repeating are all very cool)
    
    //helps manage movement stuff (sets action, switches direction)
    
    func faceRightDirection(destination: CGPoint) {
        
        if self.position.x < destination.x {
            if direction != 1 {
                direction = 1
                self.xScale = self.xScale * -1
            }
            
        } else if self.position.x > destination.x {
            if direction != -1 {
                direction = -1
                self.xScale = self.xScale * -1
            }
        }
        
    }
    
    //How can we link the scene to the sprites within the NSOrganismSprite class?
    func introduce() {
        
        spriteStatus = .Introducing
        
        let randomSide = Int(arc4random_uniform(2))
        if randomSide > 1 {
            self.position = CGPoint(x: scene!.size.width/2 + 100, y: scene!.size.height/2 * -1 + 50)
            direction = -1
        } else {
            self.position = CGPoint(x: scene!.size.width/2 * -1 - 100, y: scene!.size.height/2 * -1 + 50)
            direction = 1
            self.xScale = self.xScale * -1
        }
        
        let destination = randomPointOnGround()
        faceRightDirection(destination: destination)
        
        self.run(SKAction.move(to: destination, duration: 3))
        
    }
    
    func markForDeath() {
        
        switch spriteStatus {
            
        case .Standby, .Introducing:
            spriteStatus = .MarkedForDeath
            self.removeAllActions()
            
        case .Hunting:
            spriteStatus = .MarkedForDeath
            target!.die()
            self.removeAllActions()
            
        //case .Introducing: die()
            
        case .Dying: break
            
        case .Killed: break
            
        case .MarkedForDeath: break
            
        }
    }
    
    let killedAnimation = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.25)
    let disintegrate = SKAction.fadeOut(withDuration: 1)
    let delete = SKAction.removeFromParent() //How to completely delete the SKOrganismNode object?
    
    func die() {
        
        switch spriteStatus {
            
        case .Standby, .Introducing:
            spriteStatus = .Dying
            
            self.removeAllActions()
            self.run(SKAction.sequence([disintegrate, delete]))
            
        /*case .Introducing:
            spriteStatus = .Dying
            let exit = action!.reversed()
            direction *= -1
            sprite.xScale = sprite.xScale * -1
            action = SKAction.sequence([exit, delete])
            
            sprite.removeAllActions()
            sprite.run(action!)*/
            
        case .Hunting:
            spriteStatus = .Dying
            target!.die()
            self.removeAllActions()
            self.run(SKAction.sequence([disintegrate, delete]))
            
        case .MarkedForDeath:
            spriteStatus = .Dying
            self.removeAllActions()
            self.run(SKAction.sequence([disintegrate, delete]))
            
        case .Killed:
            spriteStatus = .Dying
            self.removeAllActions()
            self.run(SKAction.sequence([killedAnimation, disintegrate, delete]))
            
        case .Dying: break
        }
        
    }
    
    func getKilled() {
        if spriteStatus == .MarkedForDeath {
            spriteStatus = .Killed
            die()
        } else {
            print("cannot kill SKOrganism node that isn't marked for death")
        }
    }
    
    
    func hunt(prey: SKOrganismNode) {
        
        spriteStatus = .Hunting
        
        target = prey
        let targetPosition = prey.position
        
        faceRightDirection(destination: targetPosition)
        let markPrey = SKAction.run({prey.markForDeath()})
        let attack = SKAction.move(to: targetPosition, duration: 3)
        let kill = SKAction.run({prey.getKilled()})
        let removeTarget = SKAction.run({self.target = nil})
        self.removeAllActions()
        self.run(SKAction.sequence([markPrey, attack, kill, removeTarget]))
        
    }
    
    //Comment comment comment
    
    
}
