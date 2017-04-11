//
//  GameScene.swift
//  EcoloFinal
//
//  Created by Alex Cao on 4/3/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func randomPointOnGround() -> CGPoint {
        return CGPoint(x: random(min: frame.size.width * -1 / 2 + 150, max: frame.size.width / 2 - 150), y: random(min: frame.size.height * -1 / 2 + 150, max: frame.size.height * -3 / 10))
    }
    
    // For the moment, just adding a single wolf to the view
    
    let wolf = SKSpriteNode(imageNamed: "wolf")
    
    var wolfDirection = -1
    
    override func didMove(to view: SKView) {
        
        //addOrganism(name: "wolf")
        
        wolf.position = randomPointOnGround()
        
        wolf.xScale = 0.2
        wolf.yScale = 0.2
        wolf.zPosition = 3
        
        self.addChild(wolf)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(moveOrganism), SKAction.wait(forDuration: 3.0)])))
        
    }
    
    //May reimplement later
    
    /*func addOrganism(name: String) {
        
        let organism = SKSpriteNode(imageNamed: name)
        
        /*let actualX = random(min: frame.size.width * -1 / 2 + organism.size.width/2, max: frame.size.width / 2 - organism.size.width/2)
        let actualY = random(min: frame.size.height * -1 / 2 + organism.size.height/2, max: frame.size.height * -3 / 10)*/
        organism.position = randomPointOnGround()
        
        organism.xScale = 0.2
        organism.yScale = 0.2
        organism.zPosition = 3
        
        self.addChild(organism)
        
        organism.run(SKAction.repeatForever(SKAction.sequence([SKAction.run(moveOrganism), SKAction.wait(forDuration: 4.0, withRange: 2.0)])))
        
    }
*/
    func moveOrganism() {
        
        let destination = randomPointOnGround()
        
        let actionMove = SKAction.move(to: destination, duration: TimeInterval(random(min: 4.0, max: 6.0)))
        
        if wolf.position.x < destination.x {
            if wolfDirection == 1 {
                wolf.run(actionMove)
            } else {
                wolfDirection = 1
                wolf.xScale = wolf.xScale * -1
                wolf.run(actionMove)
            }
            
        } else if wolf.position.x > destination.x {
            if wolfDirection == -1 {
                wolf.run(actionMove)
            } else {
                wolfDirection = -1
                wolf.xScale = wolf.xScale * -1
                wolf.run(actionMove)
            }
        } else {
            wolf.run(actionMove)
        }
    }
    
    //
    // Touches
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            guard let mountain = childNode(withName: "MountainNode"), let mountainButton = childNode(withName: "MountainButtonNode") else {
                break
            }
            
            if mountainButton.contains(location) {
                if mountain.alpha == 0 {
                    let animate = SKAction(named: "fadeInMountain")
                    mountain.run(animate!)
                } else if mountain.alpha == 1{
                    let animate = SKAction(named: "fadeOutMountain")
                    mountain.run(animate!)
                }
            
            }
            
        }
        
    }
    
}

