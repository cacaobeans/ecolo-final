//
//  GameScene.swift
//  EcoloFinal
//
//  Created by Alex Cao on 4/3/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol EcosystemScene {
    init(delegate: EcosystemSceneDelegate)
    func render(factors: [Factor: [Factor: Double]])
}

class GameScene: SKScene, EcosystemScene {
    
    // NEW MVC STUFF:
    required init(delegate: EcosystemSceneDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(factors: [Factor: [Factor: Double]]) {
        print("Cannot render factors yet.")
    }
    
    // Randomization helper functions:
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func randomPointOnGround() -> CGPoint {
        return CGPoint(x: random(min: frame.size.width * -1 / 2 + 150, max: frame.size.width / 2 - 150), y: random(min: frame.size.height * -1 / 2 + 75, max: frame.size.height * -3 / 10))
    }
    
    
    var wolves = [SKSpriteNode]()
    
    var wolfDirection = [SKSpriteNode: Int]()
    
    //var wolfDirection = -1
    
    func addWolf() {
        let newWolf = SKSpriteNode(imageNamed: "wolf")
        wolves.append(newWolf)
        newWolf.position = randomPointOnGround()
        
        newWolf.xScale = 0.2
        newWolf.yScale = 0.2
        newWolf.zPosition = 3
        
        wolfDirection[newWolf] = -1
        
        self.addChild(newWolf)
    }
    
    func deleteWolf() {
        if wolves.count > 0 {
            wolfDirection.removeValue(forKey: wolves[wolves.count - 1])
            wolves[wolves.count - 1].removeFromParent()
            wolves.remove(at: wolves.count - 1)
        } else {
            print("no wolves in ecosystem")
        }
        
    }
    
    override func didMove(to view: SKView) {
        
        //addOrganism(name: "wolf")
        
        for wolf in wolves {
            wolf.position = randomPointOnGround()
        
            wolf.xScale = 0.2
            wolf.yScale = 0.2
            wolf.zPosition = 3
            
            wolfDirection[wolf] = -1
            
            self.addChild(wolf)
        }
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(moveOrganisms), SKAction.wait(forDuration: Double(random(min: 2.0, max: 6.0)))])))
        
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
    
    func shortestDistanceBetweenPoints(_ p1: CGPoint, _ p2: CGPoint) -> Float {
        return hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
    }
    
    func moveOrganisms() {
        for wolf in wolves {
        let pointToGo = randomPointOnGround()
        
        var destination: CGPoint
        
        let distance = shortestDistanceBetweenPoints(wolf.position, pointToGo)
        
        if distance < 150 {
            destination = wolf.position
        } else {
            destination = pointToGo
        }
        wolf.zPosition = destination.y * -1 / 100
            
        let actionMove = SKAction.move(to: destination, duration: TimeInterval(random(min: 2.0, max: 6.0)))
        
        if wolf.position.x < destination.x {
            if wolfDirection[wolf] == 1 {
                wolf.run(actionMove)
            } else {
                wolfDirection[wolf] = 1
                wolf.xScale = wolf.xScale * -1
                wolf.run(actionMove)
            }
            
        } else if wolf.position.x > destination.x {
            if wolfDirection[wolf] == -1 {
                wolf.run(actionMove)
            } else {
                wolfDirection[wolf] = -1
                wolf.xScale = wolf.xScale * -1
                wolf.run(actionMove)
            }
        } else {
            wolf.run(actionMove)
        }
        }
    }
    
    //
    // Touches
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            guard let mountain = childNode(withName: "MountainNode"), let mountainButton = childNode(withName: "MountainButtonNode"), let addWolfButton = childNode(withName: "AddWolfButtonNode"), let deleteWolfButton = childNode(withName: "DeleteWolfButtonNode") else {
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
            
            } else if addWolfButton.contains(location) {
                addWolf()
                
            } else if deleteWolfButton.contains(location) {
                deleteWolf()
            }
            
        }
        
    }
    
}

