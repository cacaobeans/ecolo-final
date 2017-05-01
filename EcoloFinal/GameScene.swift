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
    
    func randomInt (min: Int , max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func randomPointOnGround() -> CGPoint {
        return CGPoint(x: random(min: frame.size.width * -1 / 2 + 50, max: frame.size.width / 2 - 50), y: random(min: frame.size.height * -1 / 2 + 50, max: frame.size.height * -3 / 10))
    }
    
    /*
     THINGS TO DO
     -support different types of organisms
        -need 1)array to store sprites 2)array to store direction facing
            -possibly could do an organism array of sprite arrays?
        -how to determine which organism corresponds to which sprite?
            -index in the array to correspond to a specific organism in the ecosystem?
            -perhaps the "name" variable for a factor could be used to call a specific sprite?
     -mobile vs immobile organisms
        -Something else that can be passed? (in general, if its a producer, it will be immobile, so the direction facing array will be irrelevant)
     */
    
    //dictionary storing all organism sprites
    var organisms = [String: [SKSpriteNode]]()
    
    //dictionary storing "direction" all sprites are facing
    var organismDirection = [SKSpriteNode: Int]()
    
    //dictionary storing action queues for all sprites
    var organismActions = [SKSpriteNode: [SKAction]]()
    
    
    func addOrganism(organismName: String) {
        let newOrganism = SKSpriteNode(imageNamed: organismName)
        if organisms[organismName] == nil {
            organisms[organismName] = [newOrganism]
        }
        else {
            organisms[organismName]!.append(newOrganism)
            
        }
        organismDirection[newOrganism] = -1
        
        organismActions[newOrganism].insert(<#T##newElement: Element##Element#>, at: 0)
        
        newOrganism.position = randomPointOnGround()
        
        newOrganism.xScale = 0.2
        newOrganism.yScale = 0.2
        newOrganism.zPosition = 3
        
        self.addChild(newOrganism)
    }
    
    func deleteOrganism(organismName: String) {
        
        if organisms[organismName] != nil && organisms[organismName]!.count > 0 {
            organismDirection.removeValue(forKey: organisms[organismName]![organisms[organismName]!.count - 1])
            organisms[organismName]![organisms[organismName]!.count - 1].removeFromParent()
            organisms[organismName]!.remove(at: organisms[organismName]!.count - 1)
            
        } else {
            print("no \(organismName) in ecosystem")
        }
        
    }
    
    override func didMove(to view: SKView) {
        
        for (_, organismType) in organisms {
            for organism in organismType {
        
                organism.xScale = 0.2
                organism.yScale = 0.2
                organism.zPosition = 3
            
                organismDirection[organism] = -1
            
                self.addChild(organism)
            }
        }
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(moveOrganisms), SKAction.wait(forDuration: Double(random(min: 5.0, max: 7.0)))])))
        
    }
    
    func shortestDistanceBetweenPoints(_ p1: CGPoint, _ p2: CGPoint) -> Float {
        return hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
    }
    
    func faceAndMoveToDestination(organism: SKSpriteNode, destination: CGPoint) {
        let actionMove = SKAction.move(to: destination, duration: TimeInterval(random(min: 2.0, max: 6.0)))
        
        if organism.position.x < destination.x {
            if organismDirection[organism] == 1 {
                organism.run(actionMove)
            } else {
                organismDirection[organism] = 1
                organism.xScale = organism.xScale * -1
                organism.run(actionMove)
            }
            
        } else if organism.position.x > destination.x {
            if organismDirection[organism] == -1 {
                organism.run(actionMove)
            } else {
                organismDirection[organism] = -1
                organism.xScale = organism.xScale * -1
                organism.run(actionMove)
            }
        } else {
            organism.run(actionMove)
        }
    }
    
    func moveOrganisms() {
        for (organismName, organismType) in organisms {
            
            if organismName != "arcticwildflower" { //eventually: if organismName is a name of a Producer factor contained in the Ecosystem's factors dictionary (ask the viewcontroller for info?), then don't proceed with the for loop; otherwise, proceed
                
            for organism in organismType {
                let pointToGo = randomPointOnGround()
        
                var destination: CGPoint
        
                let distance = shortestDistanceBetweenPoints(organism.position, pointToGo)
        
                if distance < 150 {
                    destination = organism.position
                } else {
                    destination = pointToGo
                }
                organism.zPosition = destination.y * -1 / 100
                
                faceAndMoveToDestination(organism: organism, destination: destination)
                }
            }
            
        }
    }
    
    func goToOrganism(_ predator: SKSpriteNode, goesTo prey: SKSpriteNode) {
        
        let destination = prey.position
        faceAndMoveToDestination(organism: predator, destination: destination)
        
    }
    
    func predatorPreyInteraction(predatorName: String, preyName: String) {
        
        if organisms[predatorName] != nil && organisms[preyName] != nil && organisms[preyName]!.count > 0 {
            let predator = organisms[predatorName]![organisms[predatorName]!.count - 1]
            let prey = organisms[preyName]![organisms[preyName]!.count - 1]
            
            predator.removeAllActions()
            prey.removeAllActions()
            
            let destination = prey.position
            let attack = SKAction.move(to: destination, duration: TimeInterval(random(min: 1.5, max: 3.0)))
            let killPrey = SKAction.run({self.deleteOrganism(organismName: preyName)})
            
            if predator.position.x < destination.x {
                if organismDirection[predator] == 1 {
                    predator.run(attack){
                        self.run(killPrey)
                    }
                } else {
                    organismDirection[predator] = 1
                    predator.xScale = predator.xScale * -1
                    predator.run(attack) {
                        self.run(killPrey)
                    }
                }
                
            } else if predator.position.x > destination.x {
                if organismDirection[predator] == -1 {
                    predator.run(attack) {
                        self.run(killPrey)
                    }
                } else {
                    organismDirection[predator] = -1
                    predator.xScale = predator.xScale * -1
                    predator.run(attack) {
                        self.run(killPrey)
                    }
                }
            } else {
                predator.run(attack) {
                    self.run(killPrey)
                }
            }
        }
        
    }
    
    //
    // Touches
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            guard let mountain = childNode(withName: "MountainNode"), let mountainButton = childNode(withName: "MountainButtonNode"), let addWolfButton = childNode(withName: "AddWolfButtonNode"), let deleteWolfButton = childNode(withName: "DeleteWolfButtonNode"), let addRabbitButton = childNode(withName: "AddRabbitButtonNode"), let deleteRabbitButton = childNode(withName: "DeleteRabbitButtonNode") else {
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
                addOrganism(organismName: "wolf")
                
            } else if deleteWolfButton.contains(location) {
                deleteOrganism(organismName: "wolf")
            
            } else if addRabbitButton.contains(location) {
                addOrganism(organismName: "rabbit")
                
            } else if deleteRabbitButton.contains(location) {
                deleteOrganism(organismName: "rabbit")
            }
                
            else {predatorPreyInteraction(predatorName: "wolf", preyName: "rabbit")}
            
        }
        
    }
    
}

