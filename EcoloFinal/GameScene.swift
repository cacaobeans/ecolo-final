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
    //init(delegate: EcosystemSceneDelegate)
    func render(factors: [Factor: [Factor: Double]])
    @discardableResult func introduceFactor(named name: String, ofType type: FactorType, ofMovementType movement: MovementType, withLevel level: Double) -> Bool
    func evolveEcosystem()
}

extension Array {
    func randomMember() -> Element? {
        guard self.count > 0 else {return nil}
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

class GameScene: SKScene, EcosystemScene {
    
    // NEW MVC STUFF:
    /*required init(delegate: EcosystemSceneDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }*/
    
    @discardableResult func introduceFactor(named name: String, ofType type: FactorType, ofMovementType movement: MovementType, withLevel level: Double) -> Bool {
        return (delegate as! EcosystemSceneDelegate).introduceFactor(named: name, ofType: type, ofMovementType: movement, withLevel: level)
    }
    
    func evolveEcosystem() {
        (delegate as! EcosystemSceneDelegate).evolveEcosystem()
    }
    
    func render(factors: [Factor: [Factor: Double]]) {
        for (factor, _) in factors {
            
            
            // If we haven't yet tried to render this factor, that means it's new and its framework needs to be introduced to the GameScene:
            if organismNodes[factor] == nil {
                organismNodes[factor] = []
            }
            
            // Determine how many sprites we need to add or subtract from each factor's population:
            let deltaFactors = desiredNumberOfSprites(factor: factor) - organismNodes[factor]!.count
            //print("\(organismNodes[factor]!.count) \(factor.name)s detected. \(desiredNumberOfSprites(factor: factor)) desired.  Adding \(deltaFactors).")
            
            // First scenario: we don't need to add or subtract anything, in which case we do nothing!
            
            // Second scenario: the population has increased in size, se we add in more individuals to match.
            // Note that the addOrganismNode function automatically sets all individuals to promenade(), so we don't need to do that here.
            if deltaFactors > 1 {
                for _ in 1 ... deltaFactors {
                    addOrganismNode(factor: factor)
                    //print("\(factor.name) added")
                }
                
                // Third scenario: the population has shrunk in size, so we use killOrganismNode an appropriate number of times.
            } else if deltaFactors < -1 {
                for _ in deltaFactors ... -1 {
                    killOrganismNode(factor: factor, relationships: factors[factor]!)
                }
            }
        }
    }
    
    func killOrganismNode(factor: Factor, relationships: [Factor: Double]) {
        // Compile arrays nodes are available for animation:
        let availablePreyNodes = organismNodes[factor]!.filter({$0.spriteStatus == .Standby || $0.spriteStatus == .Introducing})
        let huntingPreyNodes = organismNodes[factor]!.filter({$0.spriteStatus == .Hunting})
        var availablePredatorNodes = [SKOrganismNode]()
        let predators = relationships.filter({$0.value < 0 && $0.key != factor}).map({$0.key})
        for predator in predators {
            if let predatorNodes = organismNodes[predator] {
                availablePredatorNodes.append(contentsOf: predatorNodes.filter({$0.spriteStatus == .Standby || $0.spriteStatus == .Introducing}))
            }
        }
        // Pattern: (Are there possible predators? Are there available prey nodes? Are there hunting prey nodes? Are there available predator nodes?)
        switch (!predators.isEmpty, !availablePreyNodes.isEmpty, !huntingPreyNodes.isEmpty, !availablePredatorNodes.isEmpty) {
        
        case (_, false, false, _): break // Prey unavailable (i.e., already dying)
        case (false, true, _, _): availablePreyNodes.randomMember()?.die() // Prey available, no predator
        case (false, false, true, _): huntingPreyNodes.randomMember()?.die() // Prey hunting, no predator
        case (true, true, _, true): // Predator and prey available
            if let pred = availablePredatorNodes.randomMember(), let prey = availablePreyNodes.randomMember() {
                prey.markForDeath()
                pred.hunt(prey: prey)
            }
        case (true, false, true, true): // Prey hunting, predator available
            if let pred = availablePredatorNodes.randomMember(), let prey = huntingPreyNodes.randomMember() {
                prey.markForDeath()
                pred.hunt(prey: prey)
            }
        case (true, true, _, false): availablePreyNodes.randomMember()?.die() //Prey available, predator unavailable
        case (true, false, true, false): huntingPreyNodes.randomMember()?.die()// Prey hunting, predator unavailable
        default: break
        }
    }
    
    func desiredNumberOfSprites(factor: Factor) -> Int {
        return factor.standardPopulationSize * Int(ceil(log(factor.level + 1) / log(factor.populationRenderCurveLogBase)))
    }
    
    // Randomization helper functions:
    
    /*
     THINGS TO DO
     
     */
    
    //dictionary storing all organism sprites
    var organismNodes = [Factor: Set<SKOrganismNode>]()
    
    //dictionary storing "direction" all sprites are facing
    var organismNodeDirections = [SKOrganismNode: Int]()
    
    //dictionary storing action queues for all sprites
    var organismNodeActions = [SKOrganismNode: [SKAction]]()
    
    
    @discardableResult func addOrganismNode(factor: Factor) -> Bool {
        guard organismNodes[factor] != nil else {return false}
        let newOrganismNode = SKOrganismNode(factor: factor)
        newOrganismNode.xScale = 0.2
        newOrganismNode.yScale = 0.2
        newOrganismNode.zPosition = 3
        organismNodes[factor]!.insert(newOrganismNode)
        organismNodeDirections[newOrganismNode] = -1
        self.addChild(newOrganismNode)
        newOrganismNode.introduce()
        return true
    }
    
    @discardableResult func removeOrganismNode(node: SKOrganismNode) -> Bool {
        return (organismNodes[node.factor]!.remove(node) != nil) ? true : false
    }
    
    //
    // Touches
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            guard let mountain = childNode(withName: "MountainNode"), let mountainButton = childNode(withName: "MountainButtonNode"),
                let addGreyWolfButton = childNode(withName: "AddGreyWolfButtonNode"), let deleteGreyWolfButton = childNode(withName: "DeleteGreyWolfButtonNode"),
                let addArcticHareButton = childNode(withName: "AddArcticHareButtonNode"), let deleteArcticHareButton = childNode(withName: "DeleteArcticHareButtonNode"), let addArcticWildflowerButton = childNode(withName: "AddArcticWildflowerButton"), let deleteArcticWildflowerButton = childNode(withName: "DeleteArcticWildflowerButton"), let playButton = childNode(withName: "PlayButton") else {
                break
            }
            
            for (_, nodes) in organismNodes {
                for node in nodes {
                    print("\(node.factor.name) \(node.hashValue): \(node.spriteStatus) \(node.target)")
                }
            }
            
            if mountainButton.contains(location) {
                if mountain.alpha == 0 {
                    let animate = SKAction(named: "fadeInMountain")
                    mountain.run(animate!)
                } else if mountain.alpha == 1{
                    let animate = SKAction(named: "fadeOutMountain")
                    mountain.run(animate!)
                }
                
            } else if playButton.contains(location) {
                evolveEcosystem()
                //self.isPaused = false
                print("Current Sprite Statuses:")
                
            }else if addGreyWolfButton.contains(location) {
                addOrganismFromName("Grey Wolf")
                
            } else if deleteGreyWolfButton.contains(location) {
                deleteOrganismFromName("Grey Wolf")
            
            } else if addArcticHareButton.contains(location) {
                addOrganismFromName("Arctic Hare")
                
            } else if deleteArcticHareButton.contains(location) {
                deleteOrganismFromName("Arctic Hare")
                
            } else if addArcticWildflowerButton.contains(location) {
                addOrganismFromName("Arctic Wildflower")
                
            } else if deleteArcticWildflowerButton.contains(location) {
                deleteOrganismFromName("Arctic Wildflower")
            } else {
                addOrganismFromName("Penguin") //Proof of concept for aerial movement
            }
            
        }
        
    }
    
    func addOrganismFromName(_ name: String) {
        for (factor, _) in organismNodes {
            if factor.name == name {
                addOrganismNode(factor: factor)
            }
        }
    }
    
    func deleteOrganismFromName(_ name: String) {
        for (factor, _) in organismNodes {
            if factor.name == name {
                killOrganismNode(factor: factor, relationships: (delegate as! EcosystemViewController).ecosystemModel.getFactorsWithInteractions()[factor]!)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.isPaused = true
    }
    
    
    
}

