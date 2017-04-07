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
    /*
    var background = SKSpriteNode(imageNamed: "tundra")
    var sun = SKSpriteNode(imageNamed: "sun")
    var mountainButton = SKSpriteNode(imageNamed: "mountainbutton")
    var mountain = SKSpriteNode(imageNamed: "mountain")
    var flower = SKSpriteNode(imageNamed: "arcticwildflower")
    */
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override func didMove(to view: SKView) {

        
        /*backgroundColor = SKColor.blue
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = 0
        self.addChild(background)
        
        sun.position = CGPoint(x: frame.size.width / 4, y: frame.size.height - frame.size.height / 8)
        sun.zPosition = 1
        self.addChild(sun)
        
        mountainButton.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 10)
        mountainButton.xScale = 0.5
        mountainButton.yScale = 0.5
        mountainButton.zPosition = 3
        self.addChild(mountainButton)
        
        flower.position = CGPoint(x: random(min: 0, max: frame.size.width), y: random (min: 0, max: frame.size.height / 5))
        flower.xScale = 0.3
        flower.yScale = 0.3
        flower.zPosition = 1
        self.addChild(flower)
        */
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            guard let mountain = childNode(withName: "MountainNode"), let mountainButton = childNode(withName: "MountainButtonNode") else {
                break
            }
            
            if mountainButton.contains(location) {
                if mountain.isHidden {
                    mountain.isHidden = false
                } else {
                    mountain.isHidden = true
                }
            
            }
            
        }
        /*if mountainButton.contains(location) {
        
            if (mountain.parent) == nil {
                mountain.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
                mountain.zPosition = 2
                self.addChild(mountain)
                print("added mountain")
         
            } else {
                mountain.removeFromParent()
            }
        }*/
    }
}

