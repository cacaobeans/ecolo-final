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
    @discardableResult func introduceFactor(named name: String, ofType type: FactorType, withLevel level: Double) -> Bool
    func evolveEcosystem()
}

class EcosystemViewController: UIViewController, EcosystemSceneDelegate {

    var ecosystemModel: Ecosystem!
    var gameScene: EcosystemScene!
    
    
    @discardableResult func introduceFactor(named name: String, ofType type: FactorType, withLevel level: Double) -> Bool {
        return ecosystemModel.addNewFactor(named: name, ofType: type, withLevel: level)
    }
    
    func evolveEcosystem() {
        ecosystemModel.evolveEcosystem()
        gameScene.render(factors: ecosystemModel.getFactorsWithInteractions())
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ecosystemModel = Ecosystem(name: "Antarctic")
        ecosystemModel.addNewFactor(named: "Sunlight", ofType: .Resource, withLevel: 3)
        ecosystemModel.addNewFactor(named: "Phytoplankton", ofType: .Producer, withLevel: 2)
        ecosystemModel.addNewFactor(named: "Fish", ofType: .Consumer, withLevel: 4)
        ecosystemModel.addNewFactor(named: "Penguin", ofType: .Consumer, withLevel: 1)
        ecosystemModel.addNewFactor(named: "Orca", ofType: .Consumer, withLevel: 1)
        ecosystemModel.addNewFactor(named: "Leopard Seal", ofType: .Consumer, withLevel: 1)
        ecosystemModel.addNewFactor(named: "Baleen Whale", ofType: .Consumer, withLevel: 0.5)
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.  Also, get the SKScene from the loaded GKScene
        if let scene = GKScene(fileNamed: "GameScene"), let sceneNode = scene.rootNode as! GameScene? {
            
            // Because gameScene and sceneNode are reference types, they refer to the same object. This is intentional.
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
