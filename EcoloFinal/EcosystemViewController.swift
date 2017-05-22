//
//  GameViewController.swift
//  EcoloFinal
//
//  Created by Alex Cao on 4/3/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol EcosystemSceneDelegate: SKSceneDelegate {
    @discardableResult func introduceFactor(named name: String, ofType type: FactorType, ofMovementType movement: MovementType, withLevel level: Double) -> Bool
    func evolveEcosystem()
    func changeSunlightLevel(to value: CGFloat)
}

class EcosystemViewController: UIViewController, EcosystemSceneDelegate {
    
    var ecosystemModel: Ecosystem!
    var gameScene: EcosystemScene!
    
    
    @discardableResult func introduceFactor(named name: String, ofType type: FactorType, ofMovementType movement: MovementType, withLevel level: Double) -> Bool {
        return ecosystemModel.addNewFactor(named: name, ofType: type, ofMovementType: movement, withLevel: level)
    }
    
    func evolveEcosystem() {
        ecosystemModel.evolveEcosystem()
        gameScene.render(factors: ecosystemModel.getFactorsWithInteractions())
    }
    
    func changeSunlightLevel(to value: CGFloat) {
        if let sunlight: Factor = ecosystemModel.getSunlight() {
            sunlight.level = Double(value)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ecosystemModel = Ecosystem(name: "Tundra")
        ecosystemModel.addNewFactor(named: "Arctic Wildflower", ofType: .Producer, ofMovementType: .Static, withLevel: 3)
        ecosystemModel.addNewFactor(named: "Arctic Hare", ofType: .Consumer, ofMovementType: .Terrestrial, withLevel: 3)
        ecosystemModel.addNewFactor(named: "Grey Wolf", ofType: .Consumer, ofMovementType: .Terrestrial, withLevel: 1)
        //ecosystemModel.addNewFactor(named: "Penguin", ofType: .Consumer, ofMovementType: .Aerial, withLevel: 3) //These aren't actually penguins, proof of concept for aerial movement
        ecosystemModel.addNewFactor(named: "Sunlight", ofType: .Resource, ofMovementType: .Static, withLevel: 3)
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.  Also, get the SKScene from the loaded GKScene
        if let scene = GKScene(fileNamed: "GameScene"), let sceneNode = scene.rootNode as! GameScene? {
            
            // Because gameScene and sceneNode are reference types, they refer to the same object. This is intentional.
            sceneNode.delegate = self
            gameScene = sceneNode
            
            // Copy gameplay related content over to the scene
            //sceneNode.entities = scene.entities
            //sceneNode.graphs = scene.graphs
            
            // Set the scale mode to scale to fit the window
            sceneNode.scaleMode = .aspectFill
            
            // Present the scene
            if let view = self.view as! SKView? {
                view.presentScene(sceneNode)
                
                view.ignoresSiblingOrder = true
                
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
