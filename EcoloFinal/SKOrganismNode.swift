//
//  SKOrganismNode.swift
//  EcoloFinal
//
//  Created by Alex Cao on 5/1/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import SpriteKit
import GameplayKit

class SKOrganismNode{
    
    let organismName: String
    
    let sprite: SKSpriteNode
    
    var direction: Int
    
    var actionQueue: [SKAction]
    
    init(organismName: String, direction: Int) {
        
        self.organismName = organismName
        self.direction = direction
        
        
        
    }
    
}


